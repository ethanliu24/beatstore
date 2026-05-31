# frozen_string_literal: true

class DynamicTagsComponent < ApplicationComponent
  def initialize(tags:, resource:, rerender_on_resize: true, tag_data: {}, dropdown_tag_data: {})
    @tags = tags
    @resource = resource
    @rerender_on_resize = rerender_on_resize
    @tag_data = tag_data.merge({ responsive_tag_ui_target: "tag" })
    @dropdown_tag_data = dropdown_tag_data.merge({ responsive_tag_ui_target: "dropdownTag" })
  end

  private

  attr_reader :tags, :resource, :rerender_on_resize, :tag_data, :dropdown_tag_data
end
