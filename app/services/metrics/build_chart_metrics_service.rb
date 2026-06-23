# frozen_string_literal: true

module Metrics
  class BuildChartMetricsService
    def initialize(event_name:, window:)
      @event_name = event_name
      @window = window
    end
  end
end
