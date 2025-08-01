# frozen_string_literal: true

module Tracks
  class TrackComponent < ViewComponent::Base
    def initialize(track:, user:)
      @track = track
      @user = user
    end
  end
end
