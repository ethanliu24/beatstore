# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @window_size = WindowSize::ONE_MONTH
      @cum_stats, db_records = CrunchAdminAnalyticsService.new(window_size: @window_size).call
      @chron_stats = group_records(db_records)
    end

    def update_quick_stats
      window_size = params[:window_size]
      @cum_stats, db_records = CrunchAdminAnalyticsService.new(window_size:).call
      @chron_stats = group_records(db_records)

      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def group_records(db_records)
      {
        plays: group_metrics_by_time(db_records[:plays]).count,
        hearts: group_metrics_by_time(db_records[:hearts]).count,
        comments: group_metrics_by_time(db_records[:comments]).count,
        sales: group_metrics_by_time(db_records[:sales]).sum(:amount_cents).transform_values { |v| (v / 100.0).round(2) },
        free_downloads: group_metrics_by_time(db_records[:free_downloads]).count
      }
    end

    def group_metrics_by_time(stats)
      case @window
      when WindowSize::ONE_HOUR
        stats.group_by_minute(:created_at)
      when WindowSize::TWELVE_HOURS, WindowSize::ONE_DAY, WindowSize::THREE_DAYS
        stats.group_by_hour(:created_at)
      when WindowSize::ONE_WEEK, WindowSize::ONE_MONTH
        stats.group_by_day(:created_at)
      when WindowSize::SIX_MONTHS, WindowSize::ONE_YEAR
        stats.group_by_week(:created_at)
      else
        stats.group_by_day(:created_at)
      end
    end
  end
end
