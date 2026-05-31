# frozen_string_literal: true

class TrackRecommendationComponent < ApplicationComponent
  def initialize(track_recommendation:)
    @recommendation = track_recommendation
  end

  private

  attr_reader :recommendation
end
