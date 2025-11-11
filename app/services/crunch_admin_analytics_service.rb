# frozen_string_literal: true

class CrunchAdminAnalyticsService
  def initialize(window_size:)
    @window = window_size
    @time_frame = time_frame(@window)
  end

  def call
    plays = get_analytics(Track::Play)
    hearts = get_analytics(Track::Heart)
    comments = get_analytics(Comment)
    sales = get_analytics(Transaction).where(status: Transaction.statuses[:completed])
    # TODO add free downloads model
    # free_downloads = get_analytics()

    case @stats_type
    when :chronological
      {
        plays: plays.order(created_at: :asc),
        hearts: hearts.order(created_at: :asc),
        comments: comments.order(created_at: :asc),
        sales: sales.order(created_at: :asc)
      }
    else
      {
        plays: plays.count,
        hearts: hearts.count,
        comments: comments.count,
        revenue: Money.new(sales.reduce(0) { |acc, t| acc + t.amount_cents }).format
      }
    end
  end

  private

  def get_analytics(entity)
    entity.where(created_at: @time_frame..Time.current)
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

  def time_frame(window)
    case window
    when WindowSize::ONE_HOUR
      1.hour.ago
    when WindowSize::TWELVE_HOURS
      12.hours.ago
    when WindowSize::ONE_DAY
      1.day.ago
    when WindowSize::THREE_DAYS
      3.days.ago
    when WindowSize::ONE_WEEK
      1.week.ago
    when WindowSize::ONE_MONTH
      1.month.ago
    when WindowSize::SIX_MONTHS
      6.months.ago
    when WindowSize::ONE_YEAR
      1.year.ago
    end
  end
end
