class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    if current_user.update(user_params)
      # TODO display toast on success
      redirect_to edit_users_profile_path
    else
      # TODO display toast on failure
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :biography, :profile_picture)
  end
end
