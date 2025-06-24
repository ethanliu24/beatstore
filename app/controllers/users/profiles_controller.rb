class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    # TODO display toast on success
  end

  private

  def user_params
    params.require(:user).permit()
  end
end
