# frozen_string_literal: true

module Tracks
  class ListComponent < ViewComponent::Base
    def initialize(tracks:, current_user:, options: {})
      @tracks = tracks
      @current_user = current_user
      @render_message_if_empty = unless options[:render_message_if_empty].nil?
        options[:render_message_if_empty]
      else
        true
      end
    end

    private

    attr_reader :tracks, :current_user, :render_message_if_empty
  end
end
