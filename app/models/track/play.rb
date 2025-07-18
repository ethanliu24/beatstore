class Track::Play < ApplicationRecord
  self.table_name = "track_plays"

  belongs_to :user, optional: true
  belongs_to :track, optional: true
end
