# frozen_string_literal: true

# Meant to be used with CrunchAdminAnalyticsService
class QuickStat
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

  attr_reader :name, :cum_stat, :chron_stat

  def initialize(name:, relation:, window:)
    @name = name
    @relation = relation
    @window = window
  end

  def cum_stat
    @cum_stat ||= calculate_cum_stat
  end

  def chron_stat
    @chron_stat ||= calculate_chron_stat
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
end
