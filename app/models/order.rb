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
  validates :subtotal_cents, numericality: { greater_than_or_equal_to: 0 }

  before_update :prevent_core_changes_if_paid
  before_destroy :prevent_destroy

  private

  # immutability after payment
  def prevent_core_changes_if_paid
    if paid? && (changed & %w[subtotal_cents currency user_id]).any?
      errors.add(:base, "Cannot modify order details once paid")
      throw(:abort)
    end
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "Orders are immutable"
  end
end
