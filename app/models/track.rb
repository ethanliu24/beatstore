class Track < ApplicationRecord
  # before_validation :adjust_visibility

  # === Constants ===
  VALID_KEYS = %w[C C# D D# Db E Eb F F# G G# Gb A A# Ab B Bb].freeze
  MAX_DESCRIPTION_LENGTH = 200
  GENRES = [ "Hip Hop", "Trap", "R&B", "Boom Bap", "New Jazz", "Plugnb" ].freeze
  SIMILAR_TRACKS_BPM_RANGE = 10

  # === Validations ===
  validates :title, presence: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }, allow_blank: true
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :genre, presence: true, inclusion: { in: GENRES }
  validates :key, format: {
    with: /\A(#{VALID_KEYS.join('|')}) (MAJOR|MINOR)\z/,
    message: "must be a valid key, e.g. 'C MAJOR' or 'A# MINOR'"
  }, allow_blank: true

  # === Relationships ===
  has_one_attached :tagged_mp3
  has_one_attached :untagged_mp3
  has_one_attached :untagged_wav
  has_one_attached :track_stems
  has_one_attached :project_file
  has_one_attached :cover_photo

  has_many :hearts, class_name: "Track::Heart"
  has_many :hearted_by_users, through: :hearts, source: :user
  has_many :plays, class_name: "Track::Play"
  has_many :tags, class_name: "Track::Tag", dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true
  has_many :comments, as: :entity, dependent: :destroy

  scope :similar_tracks, ->(base_track) {
    find_by_sql([
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
        base_track.genre,
        base_track.id,
        base_track.genre,
        base_track.bpm - SIMILAR_TRACKS_BPM_RANGE,
        base_track.bpm + SIMILAR_TRACKS_BPM_RANGE,
        Array(base_track.tags.pluck(:name))
    ])
  }

  class << self
    def ransackable_attributes(auth_object = nil)
      base = [
        "title",
        "description",
        "bpm",
        "key",
        "genre",
        "tags",
        "created_at",
        "updated_at"
      ]

      base << "is_public" if auth_object&.admin?
      base
    end

    def ransackable_associations(auth_object = nil)
      [ "tags" ]
    end
  end

  # def adjust_visibility
  #   # mark track private if not all links are available
  #   required_files = [ tagged_mp3, untagged_mp3, untagged_wav, track_stems, project ]
  #   self.is_public = !required_files.all?(&:blank?)
  # end

  def is_public?
    is_public
  end

  def get_tags
    tags.map { |t| "##{t.name}" }
  end

  def num_plays
    plays.count
  end

  def num_hearts
    hearts.count
  end
end
