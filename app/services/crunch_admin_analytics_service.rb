# frozen_string_literal: true

class CrunchAdminAnalyticsService
  def initialize(window)
    @window = window
    @time_frame = time_frame(window)
  end

  def call
    plays = get_analytics(Track::Play)
    hearts = get_analytics(Track::Heart)
    comments = get_analytics(Comment)
    revenue = get_analytics(Transaction).where(status: Transaction.statuses[:completed])
    # TODO add free downloads model
    # free_downloads = get_analytics()

    total_stats = {
      plays: plays.count,
      hearts: hearts.count,
      comments: comments.count,
      revenue: Money.new(revenue.reduce(0) { |acc, t| acc + t.amount_cents }).format
    }

    chrono_stats = {}

    [ total_stats, chrono_stats ]
  end

  private

  def get_analytics(entity)
    entity.where(created_at: @time_frame..Time.current)
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
