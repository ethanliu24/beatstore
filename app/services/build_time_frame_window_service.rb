# frozen_string_literal: true

class BuildTimeFrameWindowService
  class << self
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

    def group_metrics_by_time(relation, window:, column:)
      case window
      when WindowSize::ONE_HOUR
        relation.group_by_minute(column)
      when WindowSize::TWELVE_HOURS, WindowSize::ONE_DAY, WindowSize::THREE_DAYS
        relation.group_by_hour(column)
      when WindowSize::ONE_WEEK, WindowSize::ONE_MONTH
        relation.group_by_day(column)
      when WindowSize::SIX_MONTHS, WindowSize::ONE_YEAR
        relation.group_by_week(column)
      else
        relation.group_by_day(column)
      end
    end
  end
end
