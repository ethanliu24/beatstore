# frozen_string_literal: true

module ThemeHelper
  def get_theme
    cookies[:beatstore_theme] ||= "dark"
    cookies[:beatstore_theme] == "dark" ? "dark" : ""
  end
end
