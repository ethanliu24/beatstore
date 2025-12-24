class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include TrackAdminHelper
  include LicenseHelper
  include UserHelper
  include RailsIcons::Helpers
  include Turbo::FramesHelper

  delegate :icon, to: :helpers
  delegate :sort_link, to: :helpers
  delegate :player_queue_context_id, to: :helpers
end
