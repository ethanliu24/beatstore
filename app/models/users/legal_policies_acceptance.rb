# frozen_string_literal: true

module Users
  class LegalPoliciesAcceptance < ApplicationRecord
    self.table_name = "legal_policies_acceptances"

    enum :cookies_level, {
      neccessary: "neccessary",
      accept_all: "accept_all"
    }

    belongs_to :user, optional: false

    before_validation { self.cookies_level = Users::LegalPoliciesAcceptance.cookies_levels[:neccessary] if cookies_level.nil? }

    validates :user_id, uniqueness: true
    validate :timestamps_cannot_be_in_the_past, on: :update

    private

    def timestamps_cannot_be_in_the_past
      timestamp_cols = [ :tos_accepted_at, :privacy_accepted_at, :cookies_accepted_at ]

      timestamp_cols.each do |col|
        next unless attribute_changed?(col)

        previous_value = attribute_in_database(col)
        current_value = send(col)

        next if previous_value.nil? || current_value.nil?

        if current_value < previous_value
          errors.add(col, "cannot be updated to a time earlier than the previous acceptance")
        end
      end
    end
  end
end
