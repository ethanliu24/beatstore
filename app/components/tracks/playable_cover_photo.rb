# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    def initialize(track:, size:)
      @track = track
      @size = size
    end

    private

    attr_reader :track, :image_size

    def image_size
      "w-#{@size} h-#{@size}"
    end
  end
end
