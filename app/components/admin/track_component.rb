# frozen_string_literal: true

module Admin
  class TrackComponent < ApplicationComponent
    def initialize(track:, options: {})
      @track = track
      @dropdown_position = options[:dropdown_position]
    end

    private

    attr_reader :track, :dropdown_position

    def icon_dimension
      "w-3 h-3 aspect-square"
    end
  end
end
