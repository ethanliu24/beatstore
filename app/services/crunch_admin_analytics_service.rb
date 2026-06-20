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
    free_downloads = get_analytics(FreeDownload)

    users = get_analytics(User, unscoped: true)
    users_created = users.kept.where.not(role: :guest)
    users_deleted = users.discarded

    {
      plays:,
      hearts:,
      comments:,
      sales:,
      free_downloads:,
      users_created:,
      users_deleted:
    }
  end

  private

  def get_analytics(entity, unscoped: false)
    scope = unscoped ? entity.unscoped : entity
    scope.where(created_at: @time_frame..Time.current)
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
