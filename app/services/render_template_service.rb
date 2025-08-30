# frozen_string_literal: true

class RenderTemplateService
  def initialize(template:, contents:)
    @template = template
    @contents = contents
  end

  def call
    res = @template
    @contents.each do |placeholder, content|
      res = res.gsub("{{ #{placeholder} }}", content.to_s)
    end

    res
  end
end
