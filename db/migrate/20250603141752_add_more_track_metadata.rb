class AddMoreTrackMetadata < ActiveRecord::Migration[8.0]
  def change
    add_column :tracks, :genre, :string
    add_column :tracks, :description, :text
  end
end
