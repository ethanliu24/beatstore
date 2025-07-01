class RenameHeartsAndTagsTable < ActiveRecord::Migration[8.0]
  def change
    rename_table :hearts, :track_hearts
    rename_table :tags, :track_tags
  end
end
