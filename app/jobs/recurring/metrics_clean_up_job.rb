# frozen_string_literal: true

module Recurring
  class MetricsCleanUpJob < ApplicationJob
    queue_as :low

    def perform
      CleanUps::CleanUpMetricsService.call
    end
  end
end
