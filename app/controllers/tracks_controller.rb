class TracksController < ApplicationController
  # GET /tracks or /tracks.json
  def index
    # TODO pagination
    @tracks = Track.all
  end

  # GET /tracks/1 or /tracks/1.json
  def show
    @track = Track.find(params.expect(:id))
  end
end
