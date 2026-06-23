# frozen_string_literal: true

module Metrics
  class BuildChartMetricsService
    def initialize(event_name:, window:)
      @event_name = event_name
      @window = window
    end

    def line_chart_metrics(tags: {}, &tag_filter)
      relation = query_relation(tags:, &tag_filter)

      BuildTimeFrameWindowService.group_metrics_by_time(
        relation,
        window: @window,
        column: :created_at
      ).count
    end

    def pie_chart_metrics(group:, tags: {}, &tag_filter)
      relation = query_relation(tags:, &tag_filter)
      relation = relation.where("tags->>? IS NOT NULL", group.to_s)

      group_expr = Arel.sql("tags->>'#{group}'") # this should escape str safely
      relation.group(group_expr).count.compact
    end

    private

    def query_relation(tags: {}, &tag_filter)
      relation = Metric
        .where(event_name: @event_name)
        .where(created_at: BuildTimeFrameWindowService.time_frame(@window)..Time.current)
        .where("tags @> ?", tags.to_json)

      if tag_filter
        ids = relation.select { |record| tag_filter.call(record.tags) }.map(&:id)
        relation = Metric.where(id: ids)
      end

      relation
    end
  end
end
