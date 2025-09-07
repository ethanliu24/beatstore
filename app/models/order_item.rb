# frozen_string_literal: true

# This should be immutable, except when attaching files
class OrderItem < ApplicationRecord
  include Purchasable

  PUBLIC_ID_PREFIX = "OI"
  PUBLIC_ID_SUFFIX_LENGTH = 8

  belongs_to :order
  has_many_attached :files

  validates :public_id, presence: true, uniqueness: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_snapshot, :license_snapshot, :currency, presence: true
  validates :product_type, inclusion: { in: ->() { valid_product_types }, message: "%{value} is not a valid entity type" }

  before_validation :generate_public_id, if: :new_record?
  before_create :prevent_create_if_order_is_not_pending
  before_update :prevent_update_unless_attaching_files
  before_destroy :prevent_destroy

  private

  def generate_public_id
    timestamp = Time.current.strftime("%y%m%d%H%M%S")
    suffix = SecureRandom.alphanumeric(PUBLIC_ID_SUFFIX_LENGTH)
    self.public_id = "#{PUBLIC_ID_PREFIX}_#{timestamp}_#{suffix}"
  end

  def prevent_create_if_order_is_not_pending
    unless order.pending?
      errors.add(:base, "Couldn't create order item as associated order's transaction has completed or failed")
      throw(:abort)
    end
  end

  def prevent_update_unless_attaching_files
    unless order.pending?
      raise ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed"
    end

    errors.add(:base, "Cannot modify order item details other than attaching files")
    throw(:abort)
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "OrderItems are immutable"
  end
end
