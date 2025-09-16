# frozen_string_literal: true

class Users::PurchasesController < ApplicationController
  def index
    @purchases = current_or_guest_user
      .orders
      .where(status: Order.statuses[:completed])
      .order(created_at: :desc)
      .flat_map do |order|
        order.order_items.to_a
      end
  end
end
