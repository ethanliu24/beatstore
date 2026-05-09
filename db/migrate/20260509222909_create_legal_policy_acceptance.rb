class CreateLegalPolicyAcceptance < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_policies_acceptances do |t|
      t.string :tos_version, default: ""
      t.datetime :tos_accepted_at
      t.string :privacy_version, default: ""
      t.datetime :privacy_accepted_at
      t.string :cookies_version, default: ""
      t.datetime :cookies_accepted_at

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :legal_policies_acceptances, :user_id, unique: true
  end
end
