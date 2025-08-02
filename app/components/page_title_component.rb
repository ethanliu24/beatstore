# frozen_string_literal: true

class PageTitleComponent < ViewComponent::Base
  def initialize(title:, subtitle:)
    @title = title
    @subtitle = subtitle
  end

  private

  attr_reader :title, :subtitle
end
