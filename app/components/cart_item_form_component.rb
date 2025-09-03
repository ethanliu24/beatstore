# frozen_string_literal: true

class CartItemFormComponent < ApplicationComponent
  renders_one :ui

  def initialize(product_id:, product_type:, license_id:, user:, quantity: 1)
    @product_id = product_id
    @product_type = product_type
    @license_id = license_id
    @user = user
    @quantity = quantity
  end

  private

  attr_reader :product_id, :product_type, :license_id, :user, :quantity
end
