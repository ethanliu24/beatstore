# app/models/license.rb
class License < ApplicationRecord
  after_initialize :set_defaults, if: :new_record?

  monetize :price_cents, with_model_currency: :currency

  enum :contract_type, {
    free: "free",
    non_exclusive: "non_exclusive",
    exclusive: "exclusive"
  }

  validates :title, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :contract_type, presence: true

  def price
    price_cents / 100.0
  end

  def contract
    contract_details.with_indifferent_access
  end

  private

  def set_defaults
    self.currency ||= "USD"
    self.default_for_new ||= false
  end
end
