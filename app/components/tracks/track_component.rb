# frozen_string_literal: true

module Tracks
  class TrackComponent < ApplicationComponent
    def initialize(track:, current_user:, scope:)
      @track = track
      @current_user = current_user
      @scope = scope
    end

    private

    attr_reader :track, :current_user, :scope
  end
end
