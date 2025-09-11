# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }

  validates :status, :amount_cents, :currency, presence: true
end
