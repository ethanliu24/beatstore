# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    login_user(request.env["omniauth.auth"])
  end

  def failure
    # TODO add toast
    redirect_to new_user_session_path, alert: "Authentication failed"
  end

  private

  def login_user(auth)
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      # TODO add toast
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
