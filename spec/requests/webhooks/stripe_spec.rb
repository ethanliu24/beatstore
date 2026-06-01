# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Stripe Webhooks", type: :request do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:track) { create(:track_with_files) }
  let(:license) { create(:non_exclusive_license, contract_details: {
    delivers_mp3: true,
    delivers_wav: false,
    delivers_stems: true
  }) }
  let(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:) }

  before do
    OrderItem.create!(
      order: order,
      quantity: 1,
      unit_price_cents: 1000,
      currency: "USD",
      product_type: Track.name,
      product_snapshot: Snapshots::TakeTrackSnapshotService.new(track: track).call,
      license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license: license).call,
      is_immutable: false
    )

    allow(::Credentials::Stripe).to receive(:payments_webhook_secret).and_return("whsc_test")
  end

  describe "POST /webhooks/stripe/payments" do
    let(:headers) { { "HTTP_STRIPE_SIGNATURE" => "valid_sig_mock" } }

    it "sets order status to failed if payment canceled" do
      event = build_event(type: "checkout.session.async_payment_failed", event_id: "123")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      order.reload
      expect(order.status).to eq(Order.statuses[:failed])
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:failed])
    end

    it "attaches files to order item, locks state, and marks order as completed" do
      event = build_event(type: "checkout.session.completed", event_id: "123")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect(order.order_items.first.is_immutable).to be(false)

      perform_enqueued_jobs do
        post webhooks_stripe_payments_url, params: {}, headers: headers
      end

      order.reload
      current_transaction = order.payment_transaction
      first_item = order.order_items.first

      expect(response).to have_http_status(:ok)

      # Verify underlying item data state
      expect(first_item.files.attached?).to be(true)
      expect(first_item.files.count).to eq(2)
      expect(first_item.files.first.blob.filename).to eq("untagged_mp3.mp3")
      expect(first_item.files.first.content_type).to eq("audio/mpeg")
      expect(first_item.files.last.blob.filename).to eq("track_stems.zip")
      expect(first_item.files.last.content_type).to eq("application/zip")

      expect(first_item.preview_image.filename.to_s).to eq("oi_preview_cover_photo.png")
      expect(first_item.preview_image.content_type).to eq("image/png")
      expect(first_item.is_immutable).to be(true)
      expect(order.status).to eq(Order.statuses[:completed])

      # Verify payment engine tracking values
      expect(current_transaction.status).to eq(Transaction.statuses[:completed])
      expect(current_transaction.stripe_charge_id).to eq("pi_1234")
      expect(current_transaction.stripe_receipt_url).to eq("www.receipt.com")
      expect(current_transaction.customer_email).to eq("email@example.com")
      expect(current_transaction.customer_name).to eq("Customer")
      expect(current_transaction.amount_cents).to eq(9999)
      expect(current_transaction.currency).to eq("usd")

      # Outbound tracking confirmation
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Thank you for your purchase")
    end

    it "doesnt do anything if payment status is unpaid" do
      event = build_event(type: "checkout.session.completed", event_id: "123", payment_status: "unpaid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect(order.order_items.first.is_immutable).to be(false)

      perform_enqueued_jobs do
        post webhooks_stripe_payments_url, params: {}, headers: headers
      end

      order.reload

      expect(order.payment_transaction.status).to eq(Transaction.statuses[:pending])
      expect(order.status).to eq(Order.statuses[:pending])
      expect(order.order_items.first.is_immutable).to be(false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "returns a bad request if event parsing failed" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a bad request if signiture validation failed" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(
        Stripe::SignatureVerificationError.new("invalid sig", "invalid_sig_mock")
      )

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:bad_request)
    end

    it "skips unhandled events" do
      event = build_event(type: "unknown.event", event_id: "123", payment_status: "paid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:pending])
      expect(order.status).to eq(Order.statuses[:pending])
      expect(order.order_items.first.is_immutable).to be(false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  private

  def build_event(
    type:,
    event_id:,
    order_id: order.id,
    user_id: user.id,
    obj_id: "pi_1234",
    payment_intent: "pi_1234",
    payment_status: "paid"
  )
    Stripe::Event.construct_from(
      id: event_id,
      type: type,
      data: {
        object: {
          id: obj_id,
          payment_intent: payment_intent,
          payment_status: payment_status,
          receipt_url: "www.receipt.com",
          billing_details: {
            email: "email@example.com",
            name: "Customer"
          },
          metadata: {
            order_id: order_id.to_s,
            user_id: user_id.to_s
          },
          amount: 9999,
          currency: "usd"
        }
      }
    )
  end
end
