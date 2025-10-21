# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::StripeController, type: :controller do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:track) { create(:track_with_files) }
  let(:license) { create(:license) }
  let(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:) }

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
      is_immutable: false
    )

    allow(controller).to receive(:find_order) do
      controller.instance_variable_set(:@order, order)
    end

    allow(controller).to receive(:current_or_guest_user).and_return(user)
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
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:failed])
    end

    it "should set order status to filed if payment canceled" do
      event = build_event(type: "payment_intent.canceled")
      stub_event(event)

      post :payments

      expect(order.status).to eq(Order.statuses[:failed])
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:failed])
    end

    it "should attach files to order item, set it to immutable and set order status to completed" do
      event = build_event(type: "checkout.session.completed")
      stub_event(event)

      expect(order.order_items.first.is_immutable).to be(false)

      post :payments

      expect(order.order_items.first.files.attached?).to be(true)
      expect(order.order_items.first.files.count).to eq(2)
      expect(order.order_items.first.files.first.blob.filename).to eq("untagged_mp3.mp3")
      expect(order.order_items.first.files.first.content_type).to eq("audio/mpeg")
      expect(order.order_items.first.files.last.blob.filename).to eq("track_stems.zip")
      expect(order.order_items.first.files.last.content_type).to eq("application/zip")

      expect(order.order_items.first.preview_image.filename.to_s).to eq("oi_preview_cover_photo.png")
      expect(order.order_items.first.preview_image.content_type).to eq("image/png")

      expect(order.order_items.first.is_immutable).to be(true)
      expect(order.status).to eq(Order.statuses[:completed])
    end

    it "should update transaction with relavent information on charge success" do
      event = build_event(type: "charge.succeeded", obj_id: "ch_1234")
      stub_event(event)

      perform_enqueued_jobs do
        post :payments
      end

      order.reload
      transaction = order.payment_transaction

      expect(transaction.status).to eq(Transaction.statuses[:completed])
      expect(transaction.stripe_charge_id).to eq("ch_1234")
      expect(transaction.stripe_receipt_url).to eq("www.receipt.com")
      expect(transaction.customer_email).to eq("email@example.com")
      expect(transaction.customer_name).to eq("Customer")
      expect(transaction.amount_cents).to eq(9999)
      expect(transaction.currency).to eq("usd")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Thank you for your purchase")
    end

    it "should update transaction with relavent information on charge updated" do
      event = build_event(type: "charge.succeeded", obj_id: "ch_1234")
      stub_event(event)
      order.payment_transaction.update!(amount_cents: 1234)

      perform_enqueued_jobs do
        post :payments
      end

      order.reload
      transaction = order.payment_transaction

      expect(transaction.status).to eq(Transaction.statuses[:completed])
      expect(transaction.stripe_charge_id).to eq("ch_1234")
      expect(transaction.stripe_receipt_url).to eq("www.receipt.com")
      expect(transaction.customer_email).to eq("email@example.com")
      expect(transaction.customer_name).to eq("Customer")
      expect(transaction.amount_cents).to eq(9999)
      expect(transaction.currency).to eq("usd")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Thank you for your purchase")
    end
  end

  private

  def build_event(type:, obj_id: "pi_1234", payment_intent: "pi_1234")
    Stripe::Event.construct_from(
      type:,
      data: {
        object: {
          id: obj_id,
          payment_intent:,
          receipt_url: "www.receipt.com",
          billing_details: {
            email: "email@example.com",
            name: "Customer"
          },
          amount: 9999,
          currency: "usd"
        }
      }
    )
  end

  def stub_event(event)
    allow(controller).to receive(:parse_event) do
      controller.instance_variable_set(:@event, event)
    end
  end
end
