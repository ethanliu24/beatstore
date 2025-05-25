# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:user][:email])

    # Initialize a new resource object if authentication fails
    self.resource = User.new(email: params[:user][:email])

    success = false
    if user.nil?
      resource.errors.add(:email, t("authentication.email_does_not_exist"))
    elsif params[:user][:password].blank? || !user.valid_password?(params[:user][:password])
      resource.errors.add(:password, t("authentication.incorrect_password"))
    else
      success = true
    end

    if success
      super
    else
      respond_with(resource, location: new_user_session_path)
    end
  end
end
