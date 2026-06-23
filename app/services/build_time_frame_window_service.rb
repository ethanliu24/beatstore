# frozen_string_literal: true

class BuildTimeFrameWindowService
  class << self
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
