class Users::HeartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @liked_tracks = current_user.hearted_tracks
  end
end
