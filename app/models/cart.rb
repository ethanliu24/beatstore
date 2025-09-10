# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user, optional: false

  has_many :cart_items, dependent: :destroy

  def items
    cart_items
      .order(Arel.sql("CASE WHEN license_id IS NOT NULL AND product_id IS NOT NULL THEN 0 ELSE 1 END"))
      .order(created_at: :desc)
  end

  def available_items
    cart_items.filter { |item| item.available? }
  end

  def clear
    cart_items.destroy_all
  end

  def unavailable_items_count
    cart_items.count - available_items.size
  end

  def has_item?(license_id:, product_id:, product_type:)
    cart_items.exists?(license_id:, product_id:, product_type:)
  end

  def total_items
    items.count
  end

  def empty?
    total_items == 0
  end

  def total_items_price_cents
    available_items.reduce 0 do |acc, item|
      acc += item.license.price_cents
    end
  end
end
