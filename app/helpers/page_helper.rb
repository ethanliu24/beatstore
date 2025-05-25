module PageHelper
  def current_page
    if devise_controller?
      "layouts/auth_main"
    else
      "layouts/default_main"
    end
  end
end