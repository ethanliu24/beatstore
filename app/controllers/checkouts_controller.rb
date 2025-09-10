# frozen_string_literal: true

class CheckoutsController < ApplicationController
  # Creates a checkout session
  def create
    create_order_and_order_items

    session = Stripe::Checkout::Session.create({
      line_items: line_items,
      mode: "payment",
      success_url: root_url,
      cancel_url: root_url,
      metadata: {
        order_id: @order.id
      }
    })

    # TODO add success and cancel page urls

    redirect_to session.url, status: :see_other, allow_other_host: true
  end

  private

  def create_order_and_order_items
    customer = current_or_guest_user

    @order = Order.create!(
      user: customer,
      status: Order.statuses[:pending],
      subtotal_cents: customer.cart.total_items_price_cents,
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
        is_immutable: true
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
