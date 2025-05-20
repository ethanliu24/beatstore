class Track < ApplicationRecord
  before_validation :adjust_visibility

  # === Validations ===
  validates :title, presence: true
  validates :hearts, :plays, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :is_public, inclusion: { in: [ true, false ] }

  def adjust_visibility
    # mark track private if not all links are available
    required_files = [ tagged_mp3, untagged_mp3, untagged_wav, track_stems, project ]
    self.is_public = !required_files.all(&:blank?)
  end
end
