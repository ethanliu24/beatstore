class Tracks::PlaysController < ApplicationController
  include ExtractSlugToTrackId

  def create
    track_id = extract_track_id(params.expect(:track_id))
    track = Track.find(track_id)
    Track::Play.create!(track_id: track.id, user_id: current_user&.id)
    head :no_content
  end
end
