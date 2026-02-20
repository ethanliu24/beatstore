# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    def initialize(track:, size:, unit: "rem")
      @track = track
      @size = size.to_f
      @unit = unit
    end

    private

    attr_reader :track

    def image_size
      size = ("%g" % @size) + @unit
      "width: #{size}; height: #{size}; min-width: #{size};
      min-height: #{size}; max-width: #{size}; max-height: #{size};"
    end
  end
end
