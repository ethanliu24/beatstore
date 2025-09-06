# frozen_string_literal: true

# This should be immutable, except when attaching files
class OrderItem < ApplicationRecord
  belongs_to :order
  has_many_attached :files

  validates :public_id, presence: true, uniqueness: true
  validates :track_snapshot, :license_snapshot, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_update :prevent_update_unless_attaching_files
  before_destroy :prevent_destroy

  private

  def prevent_update_unless_attaching_files
    unless order.status == Order.statuses[:pending]
      raise ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed"
    end

    files_being_attached = attachment_changes[:files].present?
    other_changes = changed - [ "updated_at" ]

    if other_changes.any?
      raise ActiveRecord::ReadOnlyRecord, "OrderItem is immutable except for attaching files before payment"
    end

    unless files_being_attached
      raise ActiveRecord::ReadOnlyRecord, "OrderItem is immutable except for attaching files before payment"
    end
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "OrderItems are immutable"
  end
end
