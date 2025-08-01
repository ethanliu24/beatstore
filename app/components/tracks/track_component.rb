# frozen_string_literal: true

module Tracks
  class TrackComponent < ViewComponent::Base
    def initialize(track:, current_user:)
      @track = track
      @current_user = current_user
    end

    private

    attr_reader :track, :current_user
  end
end
