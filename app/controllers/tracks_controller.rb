class TracksController < ApplicationController
  # GET /tracks or /tracks.json
  def index
    # TODO pagination
    @tracks = Track.all.filter { |track| track.is_public? }
  end

  # GET /tracks/1 or /tracks/1.json
  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
