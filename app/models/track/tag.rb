class Track::Tag < ApplicationRecord
  self.table_name = "track_tags"

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :track_id }

  belongs_to :track
end
