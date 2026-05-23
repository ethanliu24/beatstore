# frozen_string_literal: true

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

  def render_legal_policies_acceptance_popup?
    current_page != "layouts/auth_main" &&
    !current_page?(terms_of_service_path) &&
    !current_page?(privacy_path) &&
    !current_page?(cookies_path)
  end
end
