# frozen_string_literal: true

class CartsController < ApplicationController
  def show; end

  def clear
    cart = current_or_guest_user.cart
    cart.clear
  end
end
