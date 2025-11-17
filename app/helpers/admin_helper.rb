# frozen_string_literal: true

module AdminHelper
  def render_admin_sidebar?
    (controller_name == "dashboards" && action_name == "show") ||
    (controller_name == "tracks" && action_name == "index") ||
    (controller_name == "licenses" && action_name == "index") ||
    (controller_name == "transactions" && action_name == "index") ||
    (controller_name == "transactions" && action_name == "show")
  end
end
