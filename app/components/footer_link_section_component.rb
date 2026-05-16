# frozen_string_literal: true

class FooterLinkSectionComponent < ApplicationComponent
  def initialize(section:, links:)
    @section = section  # string
    @links = links  # { link: name }, safe to assume in order
  end

  private

  attr_reader :section, :links
end
