class TracksController < ApplicationController
  def index
    # TODO pagination
    base_scope = Track.where(is_public: true)
    @q = base_scope.ransack(params[:q], auth_object: current_user)
    queried_tracks = @q.result.includes(:tags)
    @pagy, @tracks = pagy_keyset(queried_tracks, limit: 20)

    if turbo_or_xhr_request?
      render partial: "tracks/track_list", locals: { tracks: @tracks }
    end
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
