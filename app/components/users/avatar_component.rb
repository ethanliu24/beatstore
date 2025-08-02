# frozen_string_literal: true

module Users
  class AvatarComponent < ViewComponent::Base
    def initialize(user:, size:)
      @user = user
      @size = size
    end

    private

    attr_reader :user, :size
  end
end
