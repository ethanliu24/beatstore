# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::BaseController
    def show
      @window_size = WindowSize::ONE_MONTH
      @cum_stats, @chron_stats = process_data(window_size: @window_size)
    end

    def quick_stats
      window_size = params[:window_size]
      @cum_stats, @chron_stats = process_data(window_size:)

      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def process_data(window_size:)
      db_records = CrunchAdminAnalyticsService.new(window_size:).call
      cum_stats = process_cum_stats(db_records)
      chron_stats = process_chron_stats(db_records)

      [ cum_stats, chron_stats ]
    end

    def process_cum_stats(db_records)
      db_records.each_with_object({}) do |(key, relation), stats|
        stat = if key == :sales
          Money.new(relation.reduce(0) { |acc, t| acc + t.amount_cents }).format
        else
          relation.count
        end

        stats[key] = stat
      end
    end

    def process_chron_stats(db_records)
      db_records.each_with_object({}) do |(key, relation), stats|
        stat = if key == :sales
          group_metrics_by_time(relation).sum(:amount_cents).transform_values { |v| (v / 100.0).round(2) }
        else
          group_metrics_by_time(relation).count
        end

        stats[key] = stat
      end
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
