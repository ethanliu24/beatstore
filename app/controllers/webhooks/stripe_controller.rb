# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    before_action :parse_event

    def payments
      session = event.data.object
      order_id = session.metadata.order_id
      order = Order.find(order_id)

      case @event.type
      when "payment_intent.succeeded"
        # associate transaction object with order
        order.update!(status: Order.statuses[:completed])
      when "payment_intent.payment_failed"
      when "payment_intent.canceled"
        # TODO maybe one more status for canceled
        order.update!(status: Order.statuses[:failed])
      when "checkout.session.completed"
        order.order_items.each do |item|
          case item.product_type
          when Track.name
            track = Track.find(item.product_snapshot[:id])
            item.files.attach(track.untagged_mp3) if item.license_snapshot["contract_details"]["delivers_mp3"]
            item.files.attach(track.untagged_wav) if item.license_snapshot["contract_details"]["delivers_wav"]
            item.files.attach(track.track_stems) if item.license_snapshot["contract_details"]["delivers_stems"]
          end
        end

        order.user.cart.clear
      else
        # TODO Log error
      end
    end

    private

    def parse_event
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = "whsec_1234"
      @event = nil

      # TODO can log errors here + set order to failed
      begin
        @event = Stripe::Event.construct_from(
          JSON.parse(payload, sig_header, endpoint_secret)
        )
      rescue JSON::ParserError => _e
        head :bad_request
      rescue Stripe::SignatureVerificationError => _e
        head :bad_request
      end
    end
  end
end
