# frozen_string_literal: true

class CartItem < ApplicationRecord
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :product_type, inclusion: {
    in: :valid_product_types,
    message: "%{value} is not a valid entity type"
  }, if: -> { product.present? }

  belongs_to :product, polymorphic: true, optional: true
  belongs_to :license, optional: true
  belongs_to :cart, optional: false

  class << self
    def valid_product_types
      [ Track ].map { |p| p.name }
    end
  end

  def available?
    license.present? && product.present?
    # TODO also need to check product state, e.g. if track is private or not.
    # do this after non exclusive license is implemented or smth
  end

  private

  def valid_product_types
    CartItem.valid_product_types
  end
end
