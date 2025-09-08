# forzen_string_literal: true

class TakeTrackSnapshotService
  def initialize(track:)
    @track = track
  end

  def call
    @track.attributes
  end
end
