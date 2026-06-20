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
  let!(:order) { create(:order, user:) }
  let!(:order_item) { create(:order_item, order:) }
  let!(:transaction) { create(:payment_transaction, order:) }

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


    it "updates payments data metadata once only" do
      event = build_event(type: "checkout.session.completed", event_id: "123", obj_id: "co_123")
      event_2 = build_event(type: "checkout.session.canceled", event_id: "123", obj_id: "co_456")

      expected_payments_data_metadata = {
        "stripe_charge_id" => "co_123"
      }

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.metadata[Order::METADATA_PAYMENTS_DATA_KEY]).to eq(expected_payments_data_metadata)

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event_2)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.metadata[Order::METADATA_PAYMENTS_DATA_KEY]).to eq(expected_payments_data_metadata)
    end

    it "should not update other order metadata fields when updating payments data" do
      order.update!(metadata: { "test" => 123 })
      event = build_event(type: "checkout.session.completed", event_id: "123", obj_id: "co_123")
      expected_metadata = {
        "test" => 123,
        Order::METADATA_PAYMENTS_DATA_KEY => {
          "stripe_charge_id" => "co_123"
        }
      }

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.metadata).to eq(expected_metadata)
    end

    it "tracks a one time payment event" do
      event = Stripe::Event.construct_from(
        id: "123",
        type: "checkout.session.completed",
        data: { object: { metadata: {} } }
      )

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.to change(Metric, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(Metric.where(event_name: Metrics::Name::STRIPE_ONE_TIME_PAYMENT).count).to eq(1)
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

    it "skips event if it's a one time payment, i.e. order_id metadata doesnt exist" do
      event = Stripe::Event.construct_from(
        id: "123",
        type: "checkout.session.completed",
        data: { object: { metadata: {} } }
      )

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      expect {
        post webhooks_stripe_payments_url, params: {}, headers: headers
      }.not_to have_enqueued_job

      expect(response).to have_http_status(:ok)
    end
  end

  context "clear cart" do
    before do
      create(:cart_item, cart: order.user.cart, product: track, license:)
    end

    it "clears user's cart in checkout.session.completed event when payment status is paid" do
      expect(user.cart.cart_items.count).to eq(1)

      event = build_event(type: "checkout.session.completed", event_id: "123", payment_status: "paid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.user.cart.cart_items.count).to eq(0)
    end

    it "clears user's cart in checkout.session.completed event when payment status is unpaid" do
      expect(user.cart.cart_items.count).to eq(1)

      event = build_event(type: "checkout.session.completed", event_id: "123", payment_status: "unpaid")

      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post webhooks_stripe_payments_url, params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.user.cart.cart_items.count).to eq(0)
    end

    it "does not clear user's cart in any other events other than checkout.session.completed" do
      expect(user.cart.cart_items.count).to eq(1)

      (Webhooks::StripeController::HANDLED_EVENTS - [ "checkout.session.completed" ]).each do |type|
        event = build_event(type:, event_id: type)

        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        post webhooks_stripe_payments_url, params: {}, headers: headers

        expect(response).to have_http_status(:ok)
        expect(order.reload.user.cart.cart_items.count).to eq(1)
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
