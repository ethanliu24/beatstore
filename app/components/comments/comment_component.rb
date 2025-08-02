# frozen_string_literal: true

module Comments
  class CommentComponent < ViewComponent::Base
    def initialize(comment:)
      @comment = comment
    end

    private

    attr_reader :comment
  end
end
