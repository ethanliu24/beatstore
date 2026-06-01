# frozen_string_literal: true

class StripePaymentEvent < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :user, optional: true

  validates :event_id, presence: true, uniqueness: true
end
