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
        head :ok
        return
      end

      ActiveRecord::Base.transaction do
        session = event.data.object
        order = find_order(session:)
        user = find_user(session:)

        case event.type
        when "checkout.session.completed"
          payment_status = session.payment_status

          if payment_status == "unpaid"
            # TODO send email saying order processing
            return
          end

          order = find_order(session:)

          order.order_items.each do |item|
            begin
              case item.product_type
              when Track.name
                track = Track.find(item.product_snapshot["id"])
                duplicate_file(item:, file: track.untagged_mp3, attach: item.license_snapshot["contract_details"]["delivers_mp3"])
                duplicate_file(item:, file: track.untagged_wav, attach: item.license_snapshot["contract_details"]["delivers_wav"])
                duplicate_file(item:, file: track.track_stems, attach: item.license_snapshot["contract_details"]["delivers_stems"])
                item.preview_image.attach(
                  io: StringIO.new(track.cover_photo.download),
                  filename: "oi_preview_#{track.cover_photo.filename}",
                  content_type: track.cover_photo.blob&.content_type
                )
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
      end
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

    def verify_idempotency(event_id:)
      begin
        StripePaymentEvent.create!(event_id:)

        true
      rescue ActiveRecord::RecordNotUnique
        false
      rescue => e
        # TODO log error
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

    def update_transaction(transaction:, session:, status:)
      transaction.update!(
        status:,
        stripe_charge_id: session.id,
        customer_email: session.customer_details.email,
        customer_name: session.customer_details.name,
        amount_cents: session.amount_total,
        currency: session.currency
      )
    end
  end
end
