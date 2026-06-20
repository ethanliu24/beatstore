# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @window_size = WindowSize::ONE_MONTH
      @quick_stats = get_quick_stats(window_size: @window_size)
    end

    def quick_stats
      window_size = params[:window_size]
      @quick_stats = get_quick_stats(window_size:)

      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def get_quick_stats(window_size:)
      db_records = CrunchAdminAnalyticsService.new(window_size:).call
      db_records.map { |(name, relation)| QuickStats.new(name:, relation:, window: window_size) }
    end
  end
end
