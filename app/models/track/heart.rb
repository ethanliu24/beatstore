class Track::Heart < ApplicationRecord
  self.table_name = "track_hearts"

  validates :user_id, uniqueness: { scope: :track_id }

  belongs_to :user
  belongs_to :track
end
