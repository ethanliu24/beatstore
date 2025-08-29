# frozen_string_literal: true

module Licenses
  class LicensesTracksAssociation < ApplicationRecord
    self.table_name = "licenses_tracks"

    belongs_to :license
    belongs_to :track
  end
end
