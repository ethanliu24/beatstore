module PageHelper
  def current_page
    if devise_controller?
      "layouts/auth_main"
    elsif controller_path == "admin/tracks" && (action_name == "new" || action_name == "edit")
      "layouts/default_main"
    elsif controller_path.start_with?("admin/")
      "layouts/admin_main"
    else
      "layouts/default_main"
    end
  end
end
