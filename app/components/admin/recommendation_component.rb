# frozen_string_literal: true

module Admin
  class RecommendationComponent < ApplicationComponent
    def initialize(recommendation:)
      @recommendation = recommendation
    end

    private

    attr_reader :recommendation
  end
end
