# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :restrict_with_error

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }

  validates :currency, presence: true
  validates :subtotal_cents, numericality: { greater_than_or_equal_to: 0 }, presence: true

  before_update :prevent_updates_except_status
  before_destroy :prevent_destroy

  def transaction_completed?
    completed?
  end

  def transaction_failed?
    failed?
  end

  private

  def prevent_updates_except_status
    unless status_was == Order.statuses[:pending]
      errors.add(:base, "Cannot modify order details once transaction completed or failed")
      throw(:abort)
    end

    if (changed - %w[status updated_at]).any?
      errors.add(:base, "Cannot modify order details other than status")
      throw(:abort)
    end
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "Orders are immutable"
  end
end
