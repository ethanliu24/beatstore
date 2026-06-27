# frozen_string_literal: true

module CleanUps
  class CleanUpMetricsService
    class << self
      def call
        num_deleted = 0

        Rails.error.handle do
          num_deleted = Metric.where("prunes_at <= ?", Time.current).delete_all
        end

        Metric.track(Metrics::Name::METRICS_CLEAN_UP_FINISHED, tags: { num_deleted: num_deleted })
      end
    end
  end
end
