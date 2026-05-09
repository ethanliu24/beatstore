module Users
  class LegalPoliciesacceptance
    self.table_name = "legal_policies_acceptances"

    belongs_to :user, optional: false

    validates :user_id, uniqueness: true
  end
end
