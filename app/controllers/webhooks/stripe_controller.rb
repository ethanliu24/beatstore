# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :parse_event

    def payments
      # TODO update transaction with status for each
      case @event.type
      when "payment_intent.succeeded"
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

        # TODO associate transaction object with order

        # Maybe should duplicate on session create and purge if order failed
        @order.order_items.each do |item|
          case item.product_type
          when Track.name
            track = Track.find(item.product_snapshot["id"])
            duplicate_file(item:, file: track.untagged_mp3, attach: item.license_snapshot["contract_details"]["delivers_mp3"])
            duplicate_file(item:, file: track.untagged_wav, attach: item.license_snapshot["contract_details"]["delivers_wav"])
            duplicate_file(item:, file: track.track_stems, attach: item.license_snapshot["contract_details"]["delivers_stems"])
          end

          item.update!(is_immutable: true)
        end

        @order.user.cart.clear
        @order.update!(status: Order.statuses[:completed])
      end

      head :ok
    end

    private

    def parse_event
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = STRIPE_PAYMENTS_WEBHOOK_SECRET
      @event = nil

      # TODO can log errors here
      begin
        @event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      rescue JSON::ParserError, Stripe::SignatureVerificationError => _e
        head :bad_request and return
      end
    end

    def find_order(payment_intent:)
      session = Stripe::Checkout::Session.list(payment_intent:).first
      order_id = session.metadata["order_id"]
      @order = Order.find(order_id)
    end

    def duplicate_file(item:, file:, attach:)
      if attach
        item.files.attach(
          io: StringIO.new(file.download),
          filename: file.blob.filename,
          content_type: file.blob.content_type
          )
      end
    end
  end
end
