# frozen_string_literal: true

class TagComponent < ViewComponent::Base
  def initialize(name:)
    @tag = "##{name}"
  end

  private

  attr_reader :tag
end
