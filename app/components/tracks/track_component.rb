# frozen_string_literal: true

module Tracks
  class TrackComponent < ViewComponent::Base
    def initialize(track:, current_user:)
      @track = track
      @user = current_user
    end
  end
end
