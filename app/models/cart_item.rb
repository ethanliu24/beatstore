# frozen_string_literal: true

class CartItem < ApplicationRecord
  validate :license, presence: true
  validates :product_type, inclusion: {
    in: :valid_product_types,
    message: "%{value} is not a valid entity type"
  }

  belongs_to :product, polymorphic: true, optional: false
  belongs_to :license, optional: false
  belongs_to :cart, optional: false

  class << self
    def valid_product_types
      [ Track ].map { |p| p.name }
    end
  end

  private

  def valid_product_types
    CartItem.valid_product_types
  end
end
