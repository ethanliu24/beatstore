# frozen_string_literal: true

module Recurring
  class MetricsCleanUpJob < ApplicationJob
    queue_as :low

    def perform
      Metric.where("prune_at <= ?", Time.current).delete_all
    end
  end
end
