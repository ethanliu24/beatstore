class TracksController < ApplicationController
  def index
    # TODO pagination
    base_scope = Track.where(is_public: true)
    @q = base_scope.ransack(params[:q])
    @tracks = @q.result.includes(:tags)

    # TODO refactor to concern or application ctrller method
    if turbo_frame_request? || request.xhr? || request.format.turbo_stream?
      render partial: "tracks/track_list", locals: { tracks: @tracks }
    end
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
