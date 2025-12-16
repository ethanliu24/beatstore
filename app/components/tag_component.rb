# frozen_string_literal: true

class TagComponent < ApplicationComponent
  def initialize(name:)
    @tag_name = name
    @tag = "##{name}"
  end

  private

  attr_reader :tag, :tag_name
end
