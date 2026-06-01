# frozen_string_literal: true

class OrderFullfillmentService
  def initialize(order:, stripe_checkout_session:)
    @session = stripe_co_session
    @order = order
    @transaction = order.transaction
    @user = order.user
  end

  def call
    @order.order_items.each do |item|
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

    update_transaction(transaction: @transaction, session: @session, status: Transaction.statuses[:completed])
    @user.cart.clear
    @order.update!(status: Order.statuses[:completed])
    PurchaseMailer.with(user: @user, order: @order).purchase_complete.deliver_later
  end

  private

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
