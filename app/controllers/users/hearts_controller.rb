# frozen_string_literal: true

class Users::HeartsController < ApplicationController
  before_action :authenticate_user!

  def index
    hearted_tracks = current_user.available_hearted_tracks
    base_scope = Track.where(id: hearted_tracks.map(&:id))

    @q = base_scope.ransack(params[:q], auth_object: current_user)
    queried_tracks = @q.result(distinct: true).includes(:tags)
    @pagy, @liked_tracks = pagy(queried_tracks, limit: 20)
  end
end
