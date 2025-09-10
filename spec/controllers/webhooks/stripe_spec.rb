# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::StripeController, type: :controller do
  let(:user) { create(:user) }
  let(:track) { create(:track_with_files) }
  let(:license) { create(:license) }
  let(:order) { create(:order, user:) }

  before do
    sign_in user, scope: :user

    OrderItem.create!(
      order:,
      quantity: 1,
      unit_price_cents: 1000,
      currency: "USD",
      product_type: Track.name,
      product_snapshot: Snapshots::TakeTrackSnapshotService.new(track:).call,
      license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license:).call,
      is_immutable: true
    )

    allow(controller).to receive(:find_order) do
      controller.instance_variable_set(:@order, order)
    end
  end

  describe "#payments" do
    it "should set order status to completed on payment intent success event" do
      event = build_event(type: "payment_intent.succeeded")
      stub_event(event)

      post :payments

      expect(order.status).to eq(Order.statuses[:completed])
    end

    it "should set order status to filed if payment failed" do
      event = build_event(type: "payment_intent.payment_failed")
      stub_event(event)

      post :payments

      expect(order.status).to eq(Order.statuses[:failed])
    end

    it "should set order status to filed if payment canceled" do
      event = build_event(type: "payment_intent.canceled")
      stub_event(event)

      post :payments

      expect(order.status).to eq(Order.statuses[:failed])
    end

    it "should attach files to order item, set it to immutable and set order status to completed" do
      event = build_event(type: "checkout.session.completed")
      stub_event(event)

      post :payments

      expect(order.order_items.first.files.attached?).to be(true)
      expect(order.order_items.first.files.count).to eq(2)
      expect(order.order_items.first.files.first.blob.filename).to eq("untagged_mp3.mp3")
      expect(order.order_items.first.files.last.blob.filename).to eq("track_stems.zip")
      expect(order.status).to eq(Order.statuses[:completed])
    end
  end

  private

  def build_event(type:, payment_intent: "pi_1234")
    Stripe::Event.construct_from(
      type:,
      data: { object: { id: payment_intent, payment_intent: } }
    )
  end

  def stub_event(event)
    allow(controller).to receive(:parse_event) do
      controller.instance_variable_set(:@event, event)
    end
  end
end
