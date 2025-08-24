# frozen_string_literal: true

class License < ApplicationRecord
  after_initialize :set_defaults, if: :new_record?

  MAX_DESCRIPTION_LENGTH = 400

  monetize :price_cents, with_model_currency: :currency

  enum :contract_type, {
    free: "free",
    non_exclusive: "non_exclusive",
    exclusive: "exclusive"
  }

  validates :title, presence: true, uniqueness: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }, allow_blank: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :contract_type, presence: true

  def contract
    contract_details.with_indifferent_access
  end

  private

  def set_defaults
    self.currency ||= "USD"
    self.default_for_new ||= false
  end
end
