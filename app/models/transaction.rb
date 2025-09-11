# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed",
    refunded: "refunded"
  }

  validates :status, :amount_cents, :currency, presence: true
end
