# frozen_string_literal: true

module Tracks
  class TrackComponent < ApplicationComponent
    def initialize(track:, current_user:, queue_scope:)
      @track = track
      @tags = track.tags
      @current_user = current_user
      @queue_scope = queue_scope
    end

    private

    attr_reader :track, :tags, :current_user, :queue_scope
  end
end
