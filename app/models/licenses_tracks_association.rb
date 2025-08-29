# frozen_string_literal: true

class LicensesTracksAssociation < ApplicationRecord
  self.table_name = "licenses_tracks"

  belongs_to :license
  belongs_to :track
end
