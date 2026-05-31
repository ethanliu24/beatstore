# frozen_string_literal: true

class DynamicTagsComponent < ApplicationComponent
  def initialize(tags:)
    @tags = tags
  end

  private

  attr_reader :tags
end
