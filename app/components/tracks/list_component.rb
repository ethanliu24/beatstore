# frozen_string_literal: true

module Tracks
  class ListComponent < ViewComponent::Base
    def initialize(tracks:, current_user:)
      @tracks = tracks
      @current_user = current_user
    end

    private

    attr_reader :tracks, :current_user
  end
end
