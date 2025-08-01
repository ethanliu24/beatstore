# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  def icon(**kwargs)
    helpers.icon
  end
end
