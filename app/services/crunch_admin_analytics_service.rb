# frozen_string_literal: true

class CrunchAdminAnalyticsService
  class QuickStats
    # Variant filled only
    DEFAULT_ICON = "analyze"
    ICONS = {
      sales: "receipt-dollar",
      plays: "player-play",
      hearts: "heart",
      comments: "message",
      free_downloads: "file-download",
      registered_users: "user",
      deleted_users: "square-rounded-x"
    }.freeze

    attr_reader :name, :cum_stats, :chron_stats

    def initialize(name:, relation:, window:)
      @name = name
      @relation = relation
      @window = window
    end

    def cum_stats
      @cum_stats ||= calculate_cum_stat
    end

    def chron_stats
      @chron_stats ||= calculate_chron_stat
    end

    def icon
      ICONS.fetch(@name, DEFAULT_ICON)
    end

    private

    def calculate_cum_stat
      case @name
      when :sales
        Money.new(@relation.sum(:amount_cents) || 0).format
      else
        @relation.count
      end
    end

    def calculate_chron_stat
      case @name
      when :sales
        group_metrics_by_time(@relation).sum(:amount_cents).transform_values { |v| (v / 100.0).round(2) }
      else
        group_metrics_by_time(@relation).count
      end
    end

    # TODO would be helpful to refactor to a service, and take the key to group in param
    def group_metrics_by_time(relation)
      case @window
      when WindowSize::ONE_HOUR
        relation.group_by_minute(:created_at)
      when WindowSize::TWELVE_HOURS, WindowSize::ONE_DAY, WindowSize::THREE_DAYS
        relation.group_by_hour(:created_at)
      when WindowSize::ONE_WEEK, WindowSize::ONE_MONTH
        relation.group_by_day(:created_at)
      when WindowSize::SIX_MONTHS, WindowSize::ONE_YEAR
        relation.group_by_week(:created_at)
      else
        relation.group_by_day(:created_at)
      end
    end
  end

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
