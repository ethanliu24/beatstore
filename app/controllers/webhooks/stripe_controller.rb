# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :parse_event

    def payments
      # TODO update transaction with status for each
      case @event.type
      when "charge.succeeded", "charge.updated"
        payment_intent = @event.data.object.payment_intent
        find_order(payment_intent:)
        update_transaction(transaction: @order.payment_transaction, event: @event)
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

        # Maybe should duplicate on session create and purge if order failed
        @order.order_items.each do |item|
          begin
            case item.product_type
            when Track.name
              track = Track.find(item.product_snapshot["id"])
              duplicate_file(item:, file: track.untagged_mp3, attach: item.license_snapshot["contract_details"]["delivers_mp3"])
              duplicate_file(item:, file: track.untagged_wav, attach: item.license_snapshot["contract_details"]["delivers_wav"])
              duplicate_file(item:, file: track.track_stems, attach: item.license_snapshot["contract_details"]["delivers_stems"])
            end

            item.update!(is_immutable: true)
          rescue => _e
            # TODO log any errors
          end
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
      begin
        order_id = session.metadata["order_id"]
      rescue => _e
        # TODO log if any errors
      end

      @order = Order.find(order_id)
    end

    def duplicate_file(item:, file:, attach:)
      # TODO file.blob is none iff file doesn't match what the license indicates to deliver
      if attach
        item.files.attach(
          io: StringIO.new(file.download),
          filename: file.blob&.filename,
          content_type: file.blob&.content_type
          )
      end
    end

    def update_transaction(transaction:, event:)
      transaction.update!(
        status: Transaction.statuses[:pending],
        idempotency_key: event.request.idempotency_key,
        stripe_charge_id: event.data.object.id,
        stripe_receipt_url: event.data.object.receipt_url,
        customer_email: event.data.object.billing_details.email,
        customer_name: event.data.object.billing_details.name
      )
    end
  end
end
