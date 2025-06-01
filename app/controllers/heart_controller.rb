class HeartsController < ApplicationController
  before_action :authenticate_user!

  def create
    track = Track.find(params[:track_id])
    current_user.hearts.create(track: track)
    redirect_back fallback_location: root_path
  end

  def destroy
    track = Track.find(params[:track_id])
    heart = current_user.hearts.find_by(track: track)
    heart&.destroy
    redirect_back fallback_location: root_path
  end
end
