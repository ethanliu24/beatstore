# frozen_string_literal: true

class DynamicTagsComponent < ApplicationComponent
  def initialize(tags:, resource:, tag_data: {}, dropdown_tag_data: {})
    @tags = tags
    @resource = resource
    @tag_data = tag_data.merge({ responsive_tag_ui_target: "tag" })
    @dropdown_tag_data = dropdown_tag_data.merge({ responsive_tag_ui_target: "dropdownTag" })
  end

  private

  attr_reader :tags, :resource, :tag_data, :dropdown_tag_data
end
