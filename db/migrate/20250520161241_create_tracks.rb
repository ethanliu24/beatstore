class CreateTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :tracks do |t|
      t.string :title, null: false
      t.string :key
      t.integer :bpm
      t.integer :plays, default: 0, null: false
      t.boolean :is_public, default: true, null: false

      # link to track related files
      t.string :tagged_mp3
      t.string :untagged_mp3
      t.string :untagged_wav
      t.string :track_stems
      t.string :project
      t.string :cover_photo

      t.timestamps
    end
  end
end
