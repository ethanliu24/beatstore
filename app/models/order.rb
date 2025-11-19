# frozen_string_literal: true

# This should be partly immutable except for status updates. Once transaction clears it should be readonly
class Order < ApplicationRecord
  include Discard::Model

  PUBLIC_ID_PREFIX = "OR"
  PUBLIC_ID_SUFFIX_LENGTH = 8

  belongs_to :user
  has_one :payment_transaction, class_name: "Transaction", dependent: :restrict_with_error
  has_many :order_items, dependent: :restrict_with_error

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }

  monetize :subtotal_cents

  validates :public_id, presence: true, uniqueness: true
  validates :currency, presence: true
  validates :subtotal_cents, numericality: { greater_than_or_equal_to: 0 }, presence: true

  before_validation :generate_public_id, if: :new_record?
  before_update :prevent_updates_except_status
  before_destroy :prevent_destroy

  def transaction_completed?
    completed?
  end

  def transaction_failed?
    failed?
  end

  private

  def generate_public_id
    timestamp = Time.current.strftime("%y%m%d%H%M%S")
    suffix = SecureRandom.alphanumeric(PUBLIC_ID_SUFFIX_LENGTH)
    self.public_id = "#{PUBLIC_ID_PREFIX}_#{timestamp}_#{suffix}"
  end

  def prevent_updates_except_status
    if (changed - %w[status updated_at]).any?
      errors.add(:base, "Cannot modify order details other than status")
      throw(:abort)
    end
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "Orders are immutable"
  end
end
