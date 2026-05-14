class AddCookieLevels < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_policies_acceptances, :cookies_level, :string
  end
end
