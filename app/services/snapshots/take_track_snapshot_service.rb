# forzen_string_literal: true

module Snapshots
  class TakeTrackSnapshotService
    def initialize(track:)
      @track = track
    end

    def call
      @track.attributes
    end
  end
end

