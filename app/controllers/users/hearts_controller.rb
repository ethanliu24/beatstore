class Users::HeartsController < ApplicationController
  before_action :authenticate_user!

  def index
    base_scope = current_user.hearted_tracks
    @q = base_scope.ransack(params[:q], auth_object: current_user)
    queried_tracks = @q.result(distinct: true).includes(:tags)
    @pagy, @liked_tracks = pagy(queried_tracks, limit: 20)
  end
end
