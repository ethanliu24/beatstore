# frozen_string_literal: true

class Transaction < ApplicationRecord
  include Discard::Model

  belongs_to :order

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }

  monetize :amount_cents

  validates :status, :amount_cents, :currency, presence: true
end
