# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    # size: num of rem
    def initialize(track:, size:)
      @track = track
      @size = size
    end

    private

    attr_reader :track

    def image_size
      "w-[#{@size}rem] h-[#{@size}rem] min-w-[#{@size}rem] min-h-[#{@size}rem] max-w-[#{@size}rem] max-h-[#{@size}rem]"
    end
  end
end
