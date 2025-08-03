# frozen_string_literal: true

module Admin
  class TrackComponent < ViewComponent::Base
    def initialize(track:)
      @track = track
    end

    private

    attr_reader :track

    def icon_dimension
      "w-3 h-3 aspect-square"
    end
  end
end
