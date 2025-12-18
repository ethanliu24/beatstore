class Tracks::HeartsController < ApplicationController
  include ExtractSlugToTrackId

  before_action :authenticate_user!
  before_action :set_track

  def create
    current_user.hearts.create(track: @track)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    heart = current_user.hearts.find_by(track: @track)
    heart&.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_track
    id = extract_track_id(params.expect(:track_id))
    @track = Track.find(id)
  end
end
