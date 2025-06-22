# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  protected

  def configure_sign_up_params
    if params[:user][:username].blank?
      params[:user][:username] = UsernameGenerator.generate_from_email(params[:user][:email])
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
end
