class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def get_theme
    if cookies[:beatstore_theme].blank?
      "dark"
    else
      cookies[:beatstore_theme] == "dark" ? "dark" : ""
    end
  end

  helper_method :get_theme
end
