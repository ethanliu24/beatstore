# frozen_string_literal: true

class QuickStats
  include ActiveModel::Attributes

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

  attribute :name, :string
  attribute :relation

  attr_reader :name, :relation

  def initialize(name:, relation:)
    @name = name
    @relation = relation
  end

  def cum_stat
    case name
    when :sales
      Money.new(relation.reduce(0) { |acc, t| acc + t.amount_cents }).format
    else
      relation.count
    end
  end

  def chron_stat
    case name
    when :sales
      group_metrics_by_time(relation).sum(:amount_cents).transform_values { |v| (v / 100.0).round(2) }
    else
      group_metrics_by_time(relation).count
    end
  end

  def icon
    ICONS.fetch(name, DEFAULT_ICON)
  end

  def i18n_title
    "admin.dashboards.quick_stats.#{name}"
  end
end
