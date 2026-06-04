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

    it "sets order status to failed if session expired" do
      event = build_event(type: "checkout.session.async_payment_failed", event_id: "123")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      order.reload
      expect(order.status).to eq(Order.statuses[:failed])
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:failed])
    end

    it "enqueues order fulfillment job for completed session if payment status is paid" do
      event = build_event(type: "checkout.session.completed", event_id: "123", payment_status: "paid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect(order.order_items.first.is_immutable).to be(false)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:ok)
    end

    it "doesn't enqueue order fulfillment job for completed session if payment status is unpaid" do
      event = build_event(type: "checkout.session.completed", event_id: "123", payment_status: "unpaid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect(order.order_items.first.is_immutable).to be(false)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.not_to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:ok)
    end

    it "enqueues order fulfillment job for async_payment_succeeded events" do
      event = build_event(type: "checkout.session.async_payment_succeeded", event_id: "123")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect(order.order_items.first.is_immutable).to be(false)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:ok)
    end

    it "sets order status to canceled and transaction to failed if session expired" do
      event = build_event(type: "checkout.session.expired", event_id: "123")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      order.reload
      expect(order.status).to eq(Order.statuses[:canceled])
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:failed])
    end

    it "returns a bad request if event parsing failed" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.not_to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a bad request if signiture validation failed" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(
        Stripe::SignatureVerificationError.new("invalid sig", "invalid_sig_mock")
      )

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.not_to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:bad_request)
    end

    it "skips unhandled events" do
      event = build_event(type: "unknown.event", event_id: "123", payment_status: "paid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.not_to have_enqueued_job(OrderFulfillmentJob)

      expect(response).to have_http_status(:ok)
      expect(order.payment_transaction.status).to eq(Transaction.statuses[:pending])
      expect(order.status).to eq(Order.statuses[:pending])
      expect(order.order_items.first.is_immutable).to be(false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    context "idempotency detection" do
      it "skips event for completed event" do
        event = build_event(type: "checkout.session.completed", event_id: "unique_event")
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        perform_enqueued_jobs do
          expect {
            post webhooks_stripe_payments_url, params: {}, headers: headers
          }.to change(StripePaymentEvent, :count).by(1)
        end

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:completed])
        order.update_column(:status, Order.statuses[:pending])
        order.reload

        expect {
          expect {
            post webhooks_stripe_payments_url, params: {}, headers: headers
          }.not_to have_enqueued_job(OrderFulfillmentJob)
        }.not_to change(StripePaymentEvent, :count)

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:pending])
      end

      it "skips event for async_payment_succeeded event" do
        event = build_event(type: "checkout.session.async_payment_succeeded", event_id: "unique_event")
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        perform_enqueued_jobs do
          expect {
            post webhooks_stripe_payments_url, params: {}, headers: headers
          }.to change(StripePaymentEvent, :count).by(1)
        end

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:completed])
        order.update_column(:status, Order.statuses[:pending])
        order.reload

        expect {
          expect {
            post webhooks_stripe_payments_url, params: {}, headers: headers
          }.not_to have_enqueued_job(OrderFulfillmentJob)
        }.not_to change(StripePaymentEvent, :count)

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:pending])
      end

      it "skips event for async_payment_failed event" do
        event = build_event(type: "checkout.session.async_payment_failed", event_id: "unique_event")
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect {
          post webhooks_stripe_payments_url, params: {}, headers: headers
        }.to change(StripePaymentEvent, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:failed])
        order.update_column(:status, Order.statuses[:pending])
        order.reload

        expect {
          post webhooks_stripe_payments_url, params: {}, headers: headers
        }.not_to change(StripePaymentEvent, :count)

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq(Order.statuses[:pending])
      end
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
          customer_details: {
            email: "email@example.com",
            name: "Customer"
          },
          metadata: {
            order_id: order_id.to_s,
            user_id: user_id.to_s
          },
          amount_total: 9999,
          currency: "usd"
        }
      }
    )
  end
end
