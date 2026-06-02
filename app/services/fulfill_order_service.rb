# frozen_string_literal: true

class FulfillOrderService
  class OrderFulfillmentFailed < StandardError; end

  class Input
    include ActiveModel::Model

    attr_accessor \
      :order,
      :transaction,
      :user,
      :customer_email,
      :customer_name,
      :amount_cents,
      :currency,
      :stripe_charge_id

    validates :order, presence: true
    validate { errors.add(:order, "must be an Order") unless order.is_a?(Order) }
    validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :customer_name, presence: true
    validates :amount_cents, presence: true, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }
    validates :currency, presence: true, length: { is: 3 }
    validates :stripe_charge_id, allow_nil: true, presence: true

    class << self
      def build_from_stripe_checkout_session(order:, session:)
        new(
          order:,
          customer_email: session.customer_details.email,
          customer_name: session.customer_details.name,
          amount_cents: session.amount_total,
          currency: session.currency,
          stripe_charge_id: session.id,
        )
      end
    end

    def initialize(
      order:,
      customer_email:,
      customer_name:,
      amount_cents:,
      currency:,
      stripe_charge_id: nil
    )
      @order = order
      @transaction = order.payment_transaction
      @user = order.user
      @customer_email = customer_email
      @customer_name = customer_name
      @amount_cents = amount_cents
      @currency = currency
      @stripe_charge_id = stripe_charge_id
    end
  end

  class << self
    def call(input:)
      unless input.is_a?(FulfillOrderService::Input)
        raise ArgumentError, "FullfillOrderService.call input must be a FulfillOrderService::Input"
      end

      return unless @order.pending?

      begin
        ActiveRecord::Base.transaction do
          attach_files_to_order_items
          update_transaction(
            transaction: @transaction,
            status: Transaction.statuses[:completed],
            customer_email: input.customer_email,
            customer_name: input.customer_name,
            amount_cents: input.amount_cents,
            currency: input.currency,
            stripe_charge_id: input.stripe_charge_id
          )
          @user.cart.clear
          @order.update!(status: Order.statuses[:completed])
          PurchaseMailer.with(user: @user, order: @order).purchase_complete.deliver_later
        rescue => e
          # TODO log any errors
          raise OrderFulfillmentFailed, e.message
        end
      end
    end
  end

  private

  def attach_files_to_order_items
    @order.order_items.each do |item|
      begin
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
      rescue => _e
        # TODO log any errors
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

  def update_transaction(transaction:, status:, customer_email:, customer_name:, amount_cents:, currency:, stripe_charge_id:)
    transaction.update!(
      status:,
      customer_email:,
      customer_name:,
      amount_cents:,
      currency:,
      stripe_charge_id:
    )
  end
end
