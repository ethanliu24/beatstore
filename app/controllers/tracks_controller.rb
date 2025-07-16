class TracksController < ApplicationController
  def index
    # TODO pagination
    base_scope = Track.where(is_public: true)
    @q = base_scope.ransack(params[:q], auth_object: current_user)
    @tracks = @q.result.includes(:tags)

    if turbo_or_xhr_request?
      render partial: "tracks/track_list", locals: { tracks: @tracks }
    end
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
