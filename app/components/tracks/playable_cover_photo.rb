# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    def initialize(track:, size:)
      @track = track
      @size = size
    end

    private

    attr_reader :track

    def image_size
      "w-#{@size} h-#{@size} min-w-#{@size} min-h-#{@size} max-w-#{@size} max-h-#{@size}"
    end
  end
end
