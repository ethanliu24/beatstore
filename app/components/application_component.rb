class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include TrackAdminHelper
  include RailsIcons::Helpers
  include Turbo::FramesHelper
  include Ransack::Helpers::FormHelper

  delegate :icon, to: :helpers
end
