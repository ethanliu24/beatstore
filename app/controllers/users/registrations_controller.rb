# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]

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
end
