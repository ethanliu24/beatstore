class CreateTrackPlays < ActiveRecord::Migration[8.0]
  def change
    create_table :track_plays do |t|
      t.references :user, null: true, foreign_key: true
      t.references :track, null: true, foreign_key: true

      t.timestamps
    end
  end
end
