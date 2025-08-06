# frozen_string_literal: true

class PagyResponsiveComponent < ApplicationComponent
  def initialize(pagy:)
    @pagy = pagy
  end

  private

  attr_reader :pagy
end
