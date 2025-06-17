class TracksController < ApplicationController
  def index
    # TODO pagination
    @tracks = Track.where(is_public: true).order(created_at: :desc)
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
