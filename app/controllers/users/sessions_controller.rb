# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    user = User.kept.find_by(email: params[:user][:email])

    # Initialize a new resource object if authentication fails
    self.resource = User.new(email: params[:user][:email])

    if user.nil?
      resource.errors.add(:email, t("authentication.email_does_not_exist"))
    elsif params[:user][:password].blank? || !user.valid_password?(params[:user][:password])
      resource.errors.add(:password, t("authentication.incorrect_password"))
    end

    unless resource.errors.any?
      super
      transfer_guest_to_user
    else
      respond_with(resource, location: new_user_session_path)
    end
  end
end
