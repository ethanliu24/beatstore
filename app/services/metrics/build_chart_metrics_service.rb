# frozen_string_literal: true

module Metrics
  class BuildChartMetricsService
    def initialize(event_name:, window:)
      @event_name = event_name
      @window = window
    end

    def line_chart_metrics(tags: {}, &tag_filter)
      relation = Metric
        .where(event_name: @event_name)
        .where(created_at: BuildTimeFrameWindowService.time_frame(@window)..Time.current)
        .where("tags @> ?", tags.to_json)

      if tag_filter
        ids = relation.select { |record| tag_filter.call(record.tags) }.map(&:id)
        relation = Metric.where(id: ids)
      end

      metrics = BuildTimeFrameWindowService.group_metrics_by_time(
        relation,
        window: @window,
        column: :created_at
      )

      metrics.count
    end
  end
end
