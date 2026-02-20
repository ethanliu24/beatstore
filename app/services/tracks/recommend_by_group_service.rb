# frozen_string_literal: true

module Tracks
  class RecommendByGroupService
    def initialize(limit:)
      @limit = limit
    end

    def latest
      Track.publicly_available.order(created_at: :desc)
    end

    def popular(like_weight: 2)
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
          @limit
      ])

      tracks.select(&:available?)
    end

    def group_by_tag(tags:, match: :any)
      tag_names = Array(tags)
      scope = Track.publicly_available.left_joins(:tags)

      case match
      when :any
        scope.where(tags: { name: tag_names })
      when :all
        scope
          .where(tags: { name: tag_names })
          .group("tracks.id")
          .having("COUNT(DISTINCT tags.id) = ?", tag_names.size)
      else
        raise ArgumentError, "<match> must be :any or :all"
      end
    end
  end
end
