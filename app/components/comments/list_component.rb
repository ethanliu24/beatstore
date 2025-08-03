# frozen_string_literal: true

module Comments
  class ListComponent < ViewComponent::Base
    def initialize(comments:, current_user:)
      @comments = comments
      @current_user = current_user
    end

    private

    attr_reader :comments, :current_user
  end
end
