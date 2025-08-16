# app/models/license.rb
class License < ApplicationRecord
  enum contract_type: {
    free: "free",
    non_exclusive: "non_exclusive",
    exclusive: "exclusive"
  }

  validates :title, presence: true, uniqueness: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :contract_type, presence: true
  validates :default_for_new


  def price
    price_cents / 100.0
  end

  def contract
    contract_details.with_indifferent_access
  end
end
