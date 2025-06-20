# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  protected

  def configure_sign_up_params
    if params[:user][:username].blank?
      params[:user][:username] = generate_unique_username(params[:user][:email])
    end

    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [ :email, :display_name, :username, :password, :password_confirmation ]
    )
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [ :display_name, :username, :profile_picture ]
    )
  end

  private

  def generate_unique_username(email)
    base = email.split("@").first.downcase.gsub(/[^a-z0-9]/, "_")

    base = "user" if base.blank?

    # making sure the username is unique - probably a better way to generate but this will do for now
    # an ideal way is to have user enter their username? which will query the db and display whether
    # the currently entered username is valid or not.
    username = base
    suffix = 1

    while User.exists?(username: username)
      suffix += 1
      username = "#{base}#{suffix}"
    end

    username
  end
end
