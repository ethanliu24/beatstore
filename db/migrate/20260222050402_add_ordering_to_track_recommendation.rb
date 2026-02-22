class AddOrderingToTrackRecommendation < ActiveRecord::Migration[8.0]
  def change
    add_column :track_recommendations, :order, :int

    add_index :track_recommendations, :order, unique: true
  end
end
