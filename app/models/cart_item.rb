# frozen_string_literal: true

class CartItem < ApplicationRecord
  include Purchasable

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :product_type, inclusion: {
    in: ->() { valid_product_types },
    message: "%{value} is not a valid entity type"
  }, if: -> { product.present? }
  validates :license_id, uniqueness: { scope: [ :cart_id, :product_id, :product_type, :license_id ],
    message: "has already been added to this cart" }

  belongs_to :product, polymorphic: true, optional: true
  belongs_to :license, optional: true
  belongs_to :cart, optional: false

  def available?
    license.present? && product.present?
    # TODO also need to check product state, e.g. if track is private or not.
    # do this after non exclusive license is implemented or smth
  end
end
