class AddLegalPolicyAcceptanceToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :accepted_legal_policies, :jsonb, default: {}
  end
end
