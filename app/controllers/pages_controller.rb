# frozen_string_literal: true

class PagesController < ApplicationController
  RECS_LIMIT = 10

  def home
    @q = Track.ransack
    @recs = {
      new: Track.publicly_available.order(created_at: :desc).limit(RECS_LIMIT),
      popular: popular_tracks(limit: RECS_LIMIT, like_weight: 2),
      chinese: Track.publicly_available.left_joins(:tags).where(tags: { name: "chinese" }),
      gunna: Track.publicly_available.left_joins(:tags).where(tags: { name: "gunna" }),
      underground: Track.publicly_available.left_joins(:tags).where(tags: { name: "underground" }),
      rnb: Track.publicly_available.left_joins(:tags).where(tags: { name: "rnb" })
    }
  end

  private

  def popular_tracks(limit:, like_weight:)
    Track
      .publicly_available
      .left_joins(:plays, :hearts)
      .select(
        "tracks.*",
        "COUNT(DISTINCT track_plays.id) AS play_count",
        "COUNT(DISTINCT track_hearts.id) AS like_count",
        "(COUNT(DISTINCT track_plays.id) + COUNT(DISTINCT track_hearts.id) * #{like_weight}) AS popularity_score"
      )
      .group("tracks.id")
      .order("popularity_score DESC")
      .limit(limit)
  end
end
