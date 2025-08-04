class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include TrackAdminHelper
  include RailsIcons::Helpers
  include Turbo::FramesHelper

  delegate :icon, to: :helpers
end
