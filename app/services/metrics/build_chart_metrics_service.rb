# frozen_string_literal: true

module Metrics
  class BuildChartMetricsService
    def initialize(event_name:, window:)
      @event_name = event_name
      @window = window
    end

    def line_chart_metrics(tags: {}, &tag_filter)
      relation = Metric.query(@event_name, window: @window, tags:, &tag_filter)

      GroupMetricsByWindowService.group_metrics_by_time(
        relation,
        window: @window,
        column: :created_at
      )
    end

    def pie_chart_metrics(group:, tags: {}, &tag_filter)
      relation = Metric.query(@event_name, window: @window, tags:, &tag_filter)
      relation = relation.where("tags->>? IS NOT NULL", group.to_s)

      group_expr = Arel.sql(ActiveRecord::Base.sanitize_sql_array([ "tags->>?", group ]))
      relation.group(group_expr)
    end
  end
end
