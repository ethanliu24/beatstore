# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    cart = current_or_guest_user.cart
    product_type = params[:cart_item][:product_type]
    product_id = params[:cart_item][:product_id]
    license_id = params[:cart_item][:license_id]
    quantity = params[:cart_item][:quantity]

    unless current_or_guest_user.cart.has_item(license_id:, product_id:, product_type:)
      CartItem.create!(cart:, product_type:, product_id:, license_id:, quantity:)
    end
  end
end
