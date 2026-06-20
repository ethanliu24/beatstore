# frozen_string_literal: true

class CrunchAdminAnalyticsService
  def initialize(window_size:)
    @window_size = window_size
  end

  def call
    plays = get_analytics(Track::Play)
    hearts = get_analytics(Track::Heart)
    comments = get_analytics(Comment)
    sales = get_analytics(Transaction).where(status: Transaction.statuses[:completed])
    free_downloads = get_analytics(FreeDownload)

    users = get_analytics(User, unscoped: true)
    registered_users = users.kept.where.not(role: :guest)
    deleted_users = users.discarded

    {
      sales:,
      plays:,
      hearts:,
      comments:,
      free_downloads:,
      registered_users:,
      deleted_users:
    }
  end

  def get_quick_stats
    raw_data = call
    raw_data.map { |(name, relation)| QuickStats.new(name:, relation:, window: @window_size) }
  end

  private

  def get_analytics(entity, unscoped: false)
    scope = unscoped ? entity.unscoped : entity
    scope.where(created_at: time_frame(@window_size)..Time.current)
  end

  # TODO refactor to a service
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
