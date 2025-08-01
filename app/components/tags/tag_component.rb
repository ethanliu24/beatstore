# frozen_string_literal: true

module Tags
  class TagComponent < ViewComponent::Base
    def initialize(tag:)
      @tag = "##{tag.name}"
    end

    private

    attr_reader :tag
  end
end
