# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @orders = current_or_guest_user.orders
  end
end
