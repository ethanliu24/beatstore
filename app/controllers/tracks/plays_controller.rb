class Tracks::PlaysController < ApplicationController
  def create
    track = Track.find(params[:track_id])
    Track::Play.create!(track_id: track.id, user_id: current_user&.id)
    head :no_content
  end
end
