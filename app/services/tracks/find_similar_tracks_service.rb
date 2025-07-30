# frozen_string_literal: true

module Tracks
  class FindSimilarTracksService
    SIMILAR_TRACKS_BPM_RANGE = 10

    def initialize(track:)
      @track = track
    end

    def call
      Track.find_by_sql([
        <<~SQL,
          SELECT
            tracks.*,
            COUNT(tags.name) AS tag_match_count,
            (CASE WHEN tracks.genre = ? THEN 1 ELSE 0 END) AS genre_match
          FROM tracks
          LEFT JOIN track_tags AS tags ON tags.track_id = tracks.id
          WHERE
            tracks.id != ?
            AND tracks.is_public IS TRUE
            AND (
              tracks.genre = ?
              OR tracks.bpm BETWEEN ? AND ?
              OR tags.name IN (?)
            )
          GROUP BY tracks.id
          ORDER BY tag_match_count DESC, genre_match DESC, tracks.created_at DESC
        SQL
          @track.genre,
          @track.id,
          @track.genre,
          @track.bpm - SIMILAR_TRACKS_BPM_RANGE,
          @track.bpm + SIMILAR_TRACKS_BPM_RANGE,
          Array(@track.tags.pluck(:name))
      ])
    end
  end
end
