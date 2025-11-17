class Tracks::HeartsController < ApplicationController
  before_action :authenticate_user!

  def create
    @track = Track.find(params[:track_id])
    current_user.hearts.create(track: @track)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @track = Track.find(params[:track_id])
    heart = current_user.hearts.find_by(track: @track)
    heart&.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end
end
