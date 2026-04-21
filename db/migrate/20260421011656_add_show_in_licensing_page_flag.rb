class AddShowInLicensingPageFlag < ActiveRecord::Migration[8.0]
  def change
    add_column :licenses, :show_in_licensing_page, :boolean, default: false
  end
end
