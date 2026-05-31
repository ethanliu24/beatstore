# frozen_string_literal: true

class DynamicTagsComponent < ApplicationComponent
  def initialize(tags:, resource:)
    @tags = tags
    @resource = resource
  end

  private

  attr_reader :tags, :resource
end
