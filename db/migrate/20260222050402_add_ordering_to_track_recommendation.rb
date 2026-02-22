class AddOrderingToTrackRecommendation < ActiveRecord::Migration[8.0]
  def change
    add_column :track_recommendations, :display_order, :integer, null: true
  end
end
