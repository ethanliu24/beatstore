# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    # size: num of rem
    def initialize(track:, size:)
      @track = track
      @size = size.to_f
    end

    private

    attr_reader :track

    def image_size
      "width: #{@size}rem; height: #{@size}rem; min-width: #{@size}rem; min-height:
        #{@size}rem; max-width: #{@size}rem; max-height: #{@size}rem;"
    end
  end
end
