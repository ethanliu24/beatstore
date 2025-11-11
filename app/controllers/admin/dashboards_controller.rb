# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @cum_stats = CrunchAdminAnalyticsService.new(WindowSize::ONE_YEAR, :cummulative).call
    end
  end
end
