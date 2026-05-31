# frozen_string_literal: true

class TrackRecommendationComponent < ApplicationComponent
  def initialize(track_recommendation:)
    @track_recommendation = track_recommendation
  end

  private

  attr_reader :track_recommendation
end
