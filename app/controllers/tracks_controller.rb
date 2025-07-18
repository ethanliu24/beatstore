class TracksController < ApplicationController
  def index
    base_scope = Track.where(is_public: true)
    @q = base_scope.ransack(params[:q], auth_object: current_user)
    queried_tracks = @q.result.includes(:tags).order(created_at: :desc)
    @pagy, @tracks = pagy_keyset(queried_tracks, limit: 20)
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
