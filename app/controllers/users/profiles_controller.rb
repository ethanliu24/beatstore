class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit; end

  def update
    if current_user.update(user_params)
      redirect_to edit_users_profile_path, notice: t("profile.update_success")
    else
      render :edit, status: :unprocessable_content, alert: t("profile.update_fail")
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :biography, :profile_picture)
  end
end
