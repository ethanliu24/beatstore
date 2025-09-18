# frozen_string_literal: true

class CheckoutsController < ApplicationController
  # Creates a checkout session
  def create
    create_order_and_order_items

    session = Stripe::Checkout::Session.create({
      line_items: line_items,
      mode: "payment",
      success_url: success_checkout_url,
      cancel_url: cancel_checkout_url,
      metadata: {
        order_id: @order.id
      }
    })

    redirect_to session.url, status: :see_other, allow_other_host: true
  end

  def success; end

  def cancel; end

  private

  def create_order_and_order_items
    customer = current_or_guest_user

    @order = Order.create!(
      user: customer,
      status: Order.statuses[:pending],
      subtotal_cents: customer.cart.total_items_price_cents,
      currency: "USD"
    )

    # The 0 is tempory, will be updated once stripe webhook comes in with total charged amount
    Transaction.create!(
      order: @order,
      status: Transaction.statuses[:pending],
      amount_cents: 0,
      currency: "USD"
    )

    @order_items = customer.cart.available_items.map do |item|
      product_snapshot = case item.product_type
      when Track.name
        Snapshots::TakeTrackSnapshotService.new(track: item.product).call
      else
        {}
      end

      OrderItem.create!(
        order: @order,
        quantity: item.quantity,
        unit_price_cents: item.license.price_cents,
        currency: item.license.currency.presence || "USD",
        product_type: item.product_type,
        product_snapshot: product_snapshot,
        license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license: item.license).call,
        is_immutable: false
      )
    end
  end

  def line_items
    @order_items.map do |item|
      product_name = case item.product_type
      when Track.name
        item.product_snapshot["title"]
      else
        ""
      end

      {
        price_data: {
          currency: item.currency,
          unit_amount: item.unit_price_cents,
          product_data: {
            name: product_name,
            description: item.license_snapshot["title"],
            images: []  # TODO public url
          }
        },
        quantity: item.quantity
      }
    end
  end
end
