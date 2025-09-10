# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :parse_event

    def payments
      case @event.type
      when "payment_intent.succeeded"
        # associate transaction object with order
        payment_intent = @event.data.object.id
        find_order(payment_intent:)
        @order.update!(status: Order.statuses[:completed])
      when "payment_intent.payment_failed", "payment_intent.canceled"
        # TODO maybe one more status for canceled
        payment_intent = @event.data.object.id
        find_order(payment_intent:)
        @order.update!(status: Order.statuses[:failed])
      when "checkout.session.completed"
        payment_intent = @event.data.object.payment_intent
        find_order(payment_intent:)

        @order.order_items.each do |item|
          case item.product_type
          when Track.name
            track = Track.find(item.product_snapshot["id"])
            item.files.attach(track.untagged_mp3) if item.license_snapshot["contract_details"]["delivers_mp3"]
            item.files.attach(track.untagged_wav) if item.license_snapshot["contract_details"]["delivers_wav"]
            item.files.attach(track.track_stems) if item.license_snapshot["contract_details"]["delivers_stems"]
          end

          item.update!(is_immutable: true)
        end

        @order.user.cart.clear
      end

      head :ok
    end

    private

    def parse_event
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = STRIPE_PAYMENTS_WEBHOOK_SECRET
      @event = nil

      # TODO can log errors here + set order to failed
      begin
        @event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      rescue JSON::ParserError => _e
        head :bad_request and return
      rescue Stripe::SignatureVerificationError => _e
        head :bad_request and return
      end
    end

    def find_order(payment_intent:)
      session = Stripe::Checkout::Session.list(payment_intent:).first
      order_id = session.metadata["order_id"]
      @order = Order.find(order_id)
    end
  end
end
