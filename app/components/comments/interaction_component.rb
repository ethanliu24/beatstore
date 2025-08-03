# frozen_string_literal: true

module Comments
  class InteractionComponent < ApplicationComponent
    def initialize(comment:, action:, interaction_count:, current_user:, user_interacted:, icon_name:)
      @comment = comment
      @action = action
      @interaction_count = interaction_count
      @current_user = current_user
      @user_interacted = user_interacted
      @icon_name = icon_name
    end

    private

    attr_reader :comment, :interaction_count, :current_user, :icon_name

    def action_url
      @action
    end

    def user_interacted?
      @user_interacted
    end
  end
end
