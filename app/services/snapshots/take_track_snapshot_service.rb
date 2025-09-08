# forzen_string_literal: true

class TakeTrackSnapshotService
  def initialize(track:)
    @track = track
  end

  def call
    {
      id: @track.id,
      title: @track.title,
      description: @track.description,
      bpm: @track.bpm,
      key: @track.key,
      genre: @track.genre
    }.with_indifferent_access
  end
end
