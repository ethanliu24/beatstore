# frozen_string_literal: true

module Tracks
  class TrackComponent < ApplicationComponent
    def initialize(track:, current_user:, queue_scope:)
      @track = track
      @current_user = current_user
      @queue_scope = queue_scope
    end

    private

    attr_reader :track, :current_user, :queue_scope
  end
end
