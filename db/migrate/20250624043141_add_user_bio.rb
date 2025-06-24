class AddUserBio < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :biography, :text, null: false, default: ""
  end
end
