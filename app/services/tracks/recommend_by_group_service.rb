# frozen_string_literal: true

module Tracks
  class RecommendByGroupService
    def initialize(limit:)
      @limit = limit
    end

    def latest
      Track.publicly_available.order(created_at: :desc).limit(@limit)
    end

    def popular(like_weight: 2)
      tracks = Track.kept.find_by_sql([
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
        SQL
          like_weight
      ])

      tracks.select(&:available?).take(@limit)
    end

    def group_by_tags(tags, match: :any)
      tag_names = Array(tags)
      scope = Track.publicly_available.left_joins(:tags).where(tags: { name: tag_names })

      case match
      when :any
        scope.distinct.limit(@limit)
      when :all
        scope
          .group("tracks.id")
          .having("COUNT(DISTINCT tags.id) = ?", tag_names.size)
          .limit(@limit)
      else
        raise ArgumentError, "<match> must be :any or :all"
      end
    end
  end
end
