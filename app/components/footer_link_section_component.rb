# frozen_string_literal: true

class FooterLinkSectionComponent < ApplicationComponent
  def initialize(section:, links:)
    @section = section  # string
    @links = links  # [ [link, name] ]
  end

  private

  attr_reader :section, :links
end
