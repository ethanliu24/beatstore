class AddOrderingToTrackRecommendation < ActiveRecord::Migration[8.0]
  def change
    add_column :track_recommendations, :position, :integer, null: true

    add_index :track_recommendations, :position, unique: true
  end
end
