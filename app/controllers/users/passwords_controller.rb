# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  def create
    self.resource = User.new(email: params[:user][:email])
    unless User.exists?(email: params[:user][:email])
      resource.errors.add(:email, t("authentication.email_does_not_exist"))
      respond_with(resource, location: new_user_password_path)
    else
      super
    end
  end
end
