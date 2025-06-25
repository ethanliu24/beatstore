# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  def update
    super do
      username = params[:user][:username]
      current_user.update(username: username) if username && username != current_user.username
    end
  end

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
    # This is for credential updates. Regular account data updates are in Users::ProfilesController
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [ :email, :username, :password, :password_confirmation, :current_password ]
      )
  end
end
