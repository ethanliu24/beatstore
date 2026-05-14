class AddCookieLevels < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_policies_acceptances, :cookie_level, :string
  end
end
