# frozen_string_literal: true

module Comments
  class InteractionComponent < ViewComponent::Base
    def initialize(comment:, url:, interaction_count:, current_user:, user_interacted:, icon_name:)
      @comment = comment
      @url = url
      @interaction_count = interaction_count
      @current_user = current_user
      @user_interacted = user_interacted
      @icon_name = icon_name
    end

    private

    attr_reader :comment, :url, :interaction_count, :current_user, :icon_name

    def user_interacted?
      @user_interacted
    end
  end
end
