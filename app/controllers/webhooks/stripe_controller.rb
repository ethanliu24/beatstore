# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    HANDLED_EVENTS = [
      "checkout.session.completed",
      "checkout.session.expired",
      "checkout.session.async_payment_succeeded",
      "checkout.session.async_payment_failed"
    ].freeze

    def payments
      event = parse_event
      return unless event

      unless HANDLED_EVENTS.include?(event.type)
        head :ok and return
      end

      session = event.data.object

      if one_time_payment?(session:)
        # TODO log
        head :ok and return
      end

      order = find_order(session:)
      user = order.user
      event_id = event.id

      unless check_idempotency(event_id:, order:, user:)
        head :ok and return
      end

      update_order_metadata(order:, session:)

      case event.type
      when "checkout.session.completed"
        if session.payment_status == "unpaid"
          # TODO send email saying order processing
          head :ok and return
        end

        fulfill_order(order:, user:, session:)
      when "checkout.session.async_payment_succeeded"
        fulfill_order(order:, user:, session:)
      when "checkout.session.expired"
        order.update!(status: Order.statuses[:canceled])
        order.payment_transaction.update!(status: Transaction.statuses[:failed])
      when "checkout.session.async_payment_failed"
        order.update!(status: Order.statuses[:failed])
        order.payment_transaction.update!(status: Transaction.statuses[:failed])
      end

      head :ok
    end

    private

    def parse_event
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ::Credentials::Stripe.payments_webhook_secret

      begin
        Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError => _e
        # TODO log exception
        head :bad_request and return
      end
    end

    def check_idempotency(event_id:, order:, user:)
      # TODO log errors
      begin
        # db engine should handle data races, can assume this op is atomic
        StripePaymentEvent.create!(event_id:, order:, user:)

        true
      rescue ActiveRecord::RecordNotUnique
        false
      rescue ActiveRecord::RecordInvalid => e
        if e.record.errors.of_kind?(:event_id, :taken)
          false
        else
          raise e
        end
      rescue => e
        raise e
      end
    end

    def find_order(session:)
      begin
        order_id = session.metadata.order_id
      rescue => _e
        # TODO log if any errors
      end

      Order.find(order_id)
    end

    def find_user(session:)
      begin
        user_id = session.metadata.user_id
      rescue => _e
        # TODO log if any errors
      end

      User.find(user_id)
    end

    def fulfill_order(order:, user:, session:)
      fulfillment_input = FulfillOrderService::Input
        .build_from_stripe_checkout_session(order:, session:)

      OrderFulfillmentJob.perform_later(fulfillment_input:)
      user.cart.clear
    end

    def update_order_metadata(order:, session:)
      metadata = order.metadata
      payments_data_metadata_written = metadata.key?(Order::METADATA_PAYMENTS_DATA_KEY)

      return if payments_data_metadata_written

      payments_data_metadata = {
        Order::METADATA_PAYMENTS_DATA_KEY => {
          stripe_charge_id: session.id
        }
      }

      order.update!(metadata: metadata.merge(payments_data_metadata))
    end

    def one_time_payment?(session:)
      metadata = session.metadata.to_h.with_indifferent_access
      !metadata.key?(:order_id)
    end
  end
end
