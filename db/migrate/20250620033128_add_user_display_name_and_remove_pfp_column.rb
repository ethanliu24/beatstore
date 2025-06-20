class AddUserDisplayNameAndRemovePfpColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :display_name, :string, null: false, default: ""
    remove_column :users, :profile_picture, :string
  end
end
