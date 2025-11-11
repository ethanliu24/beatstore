# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @window_size = WindowSize::ONE_HOUR
      @cum_stats, @chron_stats = CrunchAdminAnalyticsService.new(window_size: @window_size).call
    end

    def update_quick_stats
      window_size = params[:window_size]
      @cum_stats, @chron_stats = CrunchAdminAnalyticsService.new(window_size:).call

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
