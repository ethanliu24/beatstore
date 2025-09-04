# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user, optional: false

  has_many :cart_items, dependent: :destroy

  def items
    cart_items
      .order(Arel.sql("CASE WHEN license_id IS NOT NULL AND product_id IS NOT NULL THEN 0 ELSE 1 END"))
      .order(created_at: :desc)
  end

  def has_item?(license_id:, product_id:, product_type:)
    !CartItem.find_by(license_id:, product_id:, product_type:).nil?
  end

  def total_items
    items.count
  end

  def empty?
    total_items == 0
  end

  def total_price
    "$0.00"
  end
end
