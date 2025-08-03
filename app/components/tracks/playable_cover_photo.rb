# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ViewComponent::Base
    def initialize(track:, size:)
      @track = track
      @size = size
    end

    private

    attr_reader :track, :image_size

    def image_size
      "w-#{@size} h-#{@size} aspect-square"
    end
  end
end
