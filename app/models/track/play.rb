class Track::Play < ApplicationRecord
  self.table_name = "track_plays"

  belongs_to :user
  belongs_to :track
end
