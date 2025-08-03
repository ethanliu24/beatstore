# frozen_string_literal: true

module Comments
  class CommentComponent < ViewComponent::Base
    def initialize(comment:, current_user:)
      @comment = comment
      @current_user = current_user
    end

    private

    attr_reader :comment, :current_user
  end
end
