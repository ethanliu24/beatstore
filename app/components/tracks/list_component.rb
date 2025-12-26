# frozen_string_literal: true

module Tracks
  class ListComponent < ApplicationComponent
    def initialize(tracks:, current_user:, queue_scope:, options: {})
      @tracks = tracks
      @current_user = current_user
      @queue_scope = queue_scope
      @options = options
      @empty_message = options[:empty_message] || ""
      @render_message_if_empty = unless options[:render_message_if_empty].nil?
        options[:render_message_if_empty]
      else
        true
      end
    end

    private

    attr_reader :tracks, :current_user, :queue_scope, :options, :render_message_if_empty, :empty_message
  end
end
