class TracksController < ApplicationController
  def index
    # TODO pagination
    @tracks = Track.all.filter { |track| track.is_public? }
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
