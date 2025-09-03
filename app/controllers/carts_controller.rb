# frozen_string_literal: true

class CartsController < ApplicationController
  def show; end

  def add_item
    cart = current_or_guest_user.cart
    product_type = params[:cart_item][:product_type]
    product_id = params[:cart_item][:product_id]
    license_id = params[:cart_item][:license_id]
    quantity = params[:cart_item][:quantity]

    if current_or_guest_user.cart.has_item(license_id:, product_id:, product_type:)
      CartItem.create!(cart:, product_type:, product_id:, license_id:, quantity:)
    end

    # TODO add toast & refresh nav bar cart
  end
end
