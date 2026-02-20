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
    tracks = Track.find_by_sql([
      <<~SQL,
        SELECT
          tracks.*,
          COALESCE(p.play_count, 0) AS play_count,
          COALESCE(l.like_count, 0) AS like_count,
          (COALESCE(p.play_count, 0) + COALESCE(l.like_count, 0) * ?) AS popularity_score
        FROM tracks
        LEFT JOIN (
          SELECT track_id, COUNT(*) AS play_count
          FROM track_plays
          GROUP BY track_id
        ) p ON p.track_id = tracks.id
        LEFT JOIN (
          SELECT track_id, COUNT(*) AS like_count
          FROM track_hearts
          GROUP BY track_id
        ) l ON l.track_id = tracks.id
        ORDER BY popularity_score DESC
        LIMIT ?
      SQL
        like_weight,
        limit
    ])

    tracks.select(&:available?)
  end
end
