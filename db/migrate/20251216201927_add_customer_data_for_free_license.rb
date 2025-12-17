class AddCustomerDataForFreeLicense < ActiveRecord::Migration[8.0]
  def change
    add_column :free_downloads, :email, :string, null: false
    add_column :free_downloads, :customer_name, :string, null: false
  end
end
