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
  validates :currency, presence: true, length: { is: 3 }
  validates :contract_type, presence: true
  validates :country, presence: true
  validates :province, presence: true

  def contract
    contract_details.with_indifferent_access
  end

  private

  def set_defaults
    self.currency ||= "USD"
    self.default_for_new ||= false
  end

  def country_and_province_exists
    country_obj = ISO3166::Country[country]
    if country_obj.nil?
      errors.add(:country, "is not a valid country")
      return
    end

    if country_obj.subdivisions.any?
      unless country_obj.subdivisions.key?(province)
        errors.add(:province, "is not valid for #{country_obj.name}")
      end
    elsif province.present?
      errors.add(:province, "#{country_obj.name} has no provinces")
    end
  end
end
