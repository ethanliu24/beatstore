class Track < ApplicationRecord
  # before_validation :adjust_visibility

  # === Constants ===
  VALID_KEYS = %w[C C# D D# Db E Eb F F# G G# Gb A A# Ab B Bb].freeze

  # === Validations ===
  validates :title, presence: true
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :is_public, inclusion: { in: [ true, false ] }
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

  has_many :hearts, dependent: :destroy
  has_many :hearted_by_users, through: :hearts, source: :user

  # def adjust_visibility
  #   # mark track private if not all links are available
  #   required_files = [ tagged_mp3, untagged_mp3, untagged_wav, track_stems, project ]
  #   self.is_public = !required_files.all?(&:blank?)
  # end

  def is_public?
    is_public
  end
end
