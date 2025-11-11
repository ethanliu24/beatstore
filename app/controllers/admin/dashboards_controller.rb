# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @total_stats, @chrono_stats = CrunchAdminAnalyticsService.new(WindowSize::ONE_YEAR).call
    end
  end
end
