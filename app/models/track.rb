class Track < ApplicationRecord
  # before_validation :adjust_visibility

  # === Constants ===
  VALID_KEYS = %w[C C# D D# Db E Eb F F# G G# Gb A A# Ab B Bb].freeze

  # === Validations ===
  validates :title, presence: true
  validates :hearts, :plays, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :key, format: {
    with: /\A(#{VALID_KEYS.join('|')}) (MAJOR|MINOR)\z/,
    message: "must be a valid key, e.g. 'C MAJOR' or 'A# MINOR'"
  }, allow_blank: true

  # def adjust_visibility
  #   # mark track private if not all links are available
  #   required_files = [ tagged_mp3, untagged_mp3, untagged_wav, track_stems, project ]
  #   self.is_public = !required_files.all?(&:blank?)
  # end

  def is_public?
    is_public
  end
end
