# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    cart = current_or_guest_user.cart
    cart_item_params = sanitize_cart_item_params.merge(cart:)
    product_id = cart_item_params[:product_id]
    product_type = cart_item_params[:product_type]
    license_id = cart_item_params[:license_id]
    @cart_item = CartItem.new(cart_item_params)

    if current_or_guest_user.cart.has_item?(license_id:, product_id:, product_type:)
      flash.now[:notice] = t("cart_item.create.has_item")
    elsif @cart_item.save
      flash.now[:notice] = t("cart_item.create.success")
    else
      flash.now[:alert] = t("cart_item.create.fail")
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("toasts", partial: "shared/toasts") }
    end
  end

  private

  def sanitize_cart_item_params
    params.require(:cart_item).permit(
      :product_type,
      :product_id,
      :license_id,
      :quantity
    )
  end
end
