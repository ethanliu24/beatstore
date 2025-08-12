class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include TrackAdminHelper
  include CollaborationHelper
  include RailsIcons::Helpers
  include Turbo::FramesHelper

  delegate :icon, to: :helpers
  delegate :sort_link, to: :helpers
end
