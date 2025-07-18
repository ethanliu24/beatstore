class TracksController < ApplicationController
  def index
    base_scope = Track.where(is_public: true)
    @q = base_scope.ransack(params[:q], auth_object: current_user)

    # need ordering for pagy_keyset, but there are dynamic order queries
    sorts = if @q.sorts.any?
      @q.sorts.map do |s|
        direction = s.dir.downcase.to_sym
        [s.name.to_sym, direction]
      end.to_h
    else
      { created_at: :desc, id: :desc }
    end

    queried_tracks = @q.result.includes(:tags).reorder(sorts)
    @pagy, @tracks = pagy_keyset(queried_tracks, limit: 20)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render :index, formats: :turbo_stream
      end
    end
  end

  def show
    # TODO redirect to not_found if invalid id
    @track = Track.find(params.expect(:id))
  end
end
