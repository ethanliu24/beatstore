class ModelSamplesForTrack < ActiveRecord::Migration[8.0]
  def change
    create_table :samples do |t|
      t.string :name, null: false
      t.string :artist, null: true
      t.string :link, null: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end
  end
end
