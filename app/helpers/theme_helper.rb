module ThemeHelper
  def get_theme
    if cookies[:beatstore_theme].blank?
      "dark"
    else
      cookies[:beatstore_theme] == "dark" ? "dark" : ""
    end
  end
end