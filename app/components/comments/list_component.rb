# frozen_string_literal: true

module Comments
  class ListComponent < ViewComponent::Base
    def initialize(comments:)
      @comments = comments
    end

    private

    attr_reader :comments
  end
end
