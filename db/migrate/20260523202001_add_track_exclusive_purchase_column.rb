class AddTrackExclusivePurchaseColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :tracks, :purchased_exclusively, :boolean, default: false
  end
end
