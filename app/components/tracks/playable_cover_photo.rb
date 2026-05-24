# frozen_string_literal: true

module Tracks
  class PlayableCoverPhoto < ApplicationComponent
    def initialize(track:, queue_scope:, size:, unit: "rem", go_to_track: true)
      @track = track
      @queue_scope = queue_scope
      @go_to_track = go_to_track
      @size = size.to_f
      @unit = unit
    end

    private

    attr_reader :track, :queue_scope, :go_to_track

    def image_size
      size = ("%g" % @size) + @unit
      "width: #{size}; height: #{size}; min-width: #{size};
      min-height: #{size}; max-width: #{size}; max-height: #{size};"
    end
  end
end
