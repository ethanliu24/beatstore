# frozen_string_literal: true

class FulfillOrderService
  class OrderFulfillmentFailedError < StandardError; end
  class OrderNotEligibleForFulfillment < StandardError; end

  class Input
    include ActiveModel::Model

    attr_accessor \
      :order,
      :transaction,
      :user,
      :customer_email,
      :customer_name,
      :amount_cents,
      :currency

    validates :order, presence: true
    validate { errors.add(:order, "must be an Order") unless order.is_a?(Order) }
    validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :customer_name, presence: true
    validates :amount_cents, presence: true, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }
    validates :currency, presence: true, length: { is: 3 }

    class << self
      def build_from_stripe_checkout_session(order:, session:)
        new(
          order:,
          customer_email: session.customer_details.email,
          customer_name: session.customer_details.name,
          amount_cents: session.amount_total,
          currency: session.currency,
        )
      end
    end

    def initialize(
      order:,
      customer_email:,
      customer_name:,
      amount_cents:,
      currency:
    )
      @order = order
      @transaction = order.payment_transaction
      @user = order.user
      @customer_email = customer_email
      @customer_name = customer_name
      @amount_cents = amount_cents
      @currency = currency
    end
  end

  class << self
    def call(input:)
      unless input.is_a?(FulfillOrderService::Input)
        raise ArgumentError, "FullfillOrderService.call input must be a FulfillOrderService::Input"
      end

      # TODO figure out how to test data race condition in unit tests
      begin
        ActiveRecord::Base.transaction do
          order = input.order
          order.lock!

          unless order.pending?
            err_data = {
              order_id: order.id,
              order_status: order.status
            }

            raise OrderNotEligibleForFulfillment, "#{err_data}"
          end

          attach_files_to_order_items(order: order)
          update_transaction(transaction: input.transaction, status: Transaction.statuses[:completed], input:)
          input.order.update!(status: Order.statuses[:completed])
          PurchaseMailer.with(user: input.user, order: input.order).purchase_complete.deliver_later
          Metric.track(Metrics::Name::ORDER_FULFILLMENT_SUCEEDED, tags: { order_id: input.order.id })
        end
      rescue OrderNotEligibleForFulfillment => e
        raise e
      rescue => e
        Rails.error.report(e)
        raise OrderFulfillmentFailedError
      end
    end

    private

    def attach_files_to_order_items(order:)
      order.order_items.each do |item|
        Rails.error.handle do
          case item.product_type
          when Track.name
            track = Track.find(item.product_snapshot["id"])
            duplicate_file(item:, file: track.untagged_mp3) if item.license_snapshot["contract_details"]["delivers_mp3"]
            duplicate_file(item:, file: track.untagged_wav) if item.license_snapshot["contract_details"]["delivers_wav"]
            duplicate_file(item:, file: track.track_stems) if item.license_snapshot["contract_details"]["delivers_stems"]

            item.preview_image.attach(
              io: StringIO.new(track.cover_photo.download),
              filename: "oi_preview_#{track.cover_photo.filename}",
              content_type: track.cover_photo.blob&.content_type
            )
          end

          item.update!(is_immutable: true)
        end
      end
    end

    def duplicate_file(item:, file:)
      item.files.attach(
        io: StringIO.new(file.download),
        filename: file.blob&.filename,
        content_type: file.blob&.content_type
      )
    end

    def update_transaction(transaction:, status:, input:)
      transaction.update!(
        status:,
        customer_email: input.customer_email,
        customer_name: input.customer_name,
        amount_cents: input.amount_cents,
        currency: input.currency,
      )
    end
  end
end
