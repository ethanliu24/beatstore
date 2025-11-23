class TracksController < ApplicationController
  SIMILAR_TRACKS_RECOMMENDATION_LIMIT = 10

  def index
    base_scope = Track.publicly_available
    @q = base_scope.ransack(params[:q], auth_object: current_user)
    queried_tracks = @q.result(distinct: true).includes(:tags).order(created_at: :desc)
    # Sorting is disabled due to incompatibilty with ransack and pagy_keyset.
    # If really need to sort, use pagy(...)
    @pagy, @tracks = pagy_keyset(queried_tracks, limit: 20)
  end

  def show
    base_scope = current_user&.admin? ? Track.kept : Track.publicly_available
    @track = base_scope.find(params.expect(:id))
    @similar_tracks = find_similar_tracks(@track)
    @licenses = @track.profitable_licenses
    @pagy, page_comments = pagy_keyset(@track.undiscarded_comments.order(created_at: :desc), limit: 10)
    @comments = if current_user
      page_comments.partition { |c| c.user_id == current_user.id }.flatten
    else
      page_comments
    end
  end

  private

  def find_similar_tracks(base_track)
    similar_tracks = Tracks::FindSimilarTracksService.new(track: base_track).call

    if similar_tracks.size < SIMILAR_TRACKS_RECOMMENDATION_LIMIT
      extra_tracks = Track
        .publicly_available
        .where.not(id: base_track.id)
        .where.not(id: similar_tracks.pluck(:id))
        .order(created_at: :desc)
        .limit(SIMILAR_TRACKS_RECOMMENDATION_LIMIT - similar_tracks.size)
        .to_a

      similar_tracks + extra_tracks
    else
      similar_tracks.first(SIMILAR_TRACKS_RECOMMENDATION_LIMIT)
    end
  end
end
