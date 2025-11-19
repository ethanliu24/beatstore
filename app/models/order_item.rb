# frozen_string_literal: true

# This should be immutable, except when attaching files
class OrderItem < ApplicationRecord
  include Discard::Model
  include Purchasable

  monetize :unit_price_cents

  belongs_to :order
  has_one_attached :preview_image
  has_many_attached :files

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_snapshot, :license_snapshot, :currency, presence: true
  validates :product_type, inclusion: { in: ->() { valid_product_types }, message: "%{value} is not a valid entity type" }

  before_create :prevent_create_if_order_is_not_pending
  before_update :prevent_update_unless_attaching_files_or_toggle_immutability
  before_destroy :prevent_destroy

  def immutable?
    is_immutable
  end

  def product_name
    case product_type
    when Track.name
      product_snapshot["title"]
    else
      ""
    end
  end

  private

  def prevent_create_if_order_is_not_pending
    unless order.pending?
      errors.add(:base, "Couldn't create order item as associated order's transaction has completed or failed")
      throw(:abort)
    end
  end

  def prevent_update_unless_attaching_files_or_toggle_immutability
    if is_immutable_was == true
      raise ActiveRecord::ReadOnlyRecord, "OrderItem is immutable"
    end

    unless (changed - %w[is_immutable updated_at]).empty?
      errors.add(:base, "Cannot modify order item details other than attaching files")
      throw(:abort)
    end
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "OrderItems are immutable"
  end
end
