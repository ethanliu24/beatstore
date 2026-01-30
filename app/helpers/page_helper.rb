module PageHelper
  def current_page
    if devise_controller?
      "layouts/auth_main"
    elsif controller_path.start_with?("admin/")
      "layouts/admin_main"
    elsif controller_name == "pages" && action_name == "home"
      "layouts/home_main"
    else
      "layouts/default_main"
    end
  end

  def hero_banner
    "stars.avif"
  end
end
