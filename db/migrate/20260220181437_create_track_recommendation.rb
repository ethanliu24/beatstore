class CreateTrackRecommendation < ActiveRecord::Migration[8.0]
  def change
    create_table :track_recommendations do |t|
      t.string :group, null: false
      t.string :tag_names, array: true
      t.boolean :disabled, null: false, default: false

      t.timestamps
    end

    add_index :track_recommendations, :group, unique: true
  end
end
