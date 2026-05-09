# frozen_string_literal: true

module Users
  class LegalPoliciesAcceptance < ApplicationRecord
    self.table_name = "legal_policies_acceptances"

    belongs_to :user, optional: false

    validates :user_id, uniqueness: true
  end
end
