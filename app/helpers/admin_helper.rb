# frozen_string_literal: true

module AdminHelper
  # controller => [pages]
  SIDEBAR_NOT_RENDERED = {
    "tracks" => [ "new", "edit" ],
    "licenses" => [ "new", "edit" ],
    "recommendations" => [ "new", "edit" ]
  }

  def render_admin_sidebar?
    !SIDEBAR_NOT_RENDERED.fetch(controller_name, []).include?(action_name)
  end
end
