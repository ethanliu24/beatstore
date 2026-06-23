# frozen_string_literal: true

class WindowSize
  ONE_HOUR = "one_hour"
  TWELVE_HOURS = "twelve_hours"
  ONE_DAY = "one_day"
  THREE_DAYS = "three_days"
  ONE_WEEK = "one_week"
  ONE_MONTH = "one_month"
  SIX_MONTHS = "six_months"
  ONE_YEAR = "one_year"

  class << self
    def sizes
      WindowSize.constants.map { |const_name| WindowSize.const_get(const_name) }
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
      else
        raise ArgumentError.new("unrecognized window size: #{window}")
      end
    end
  end
end
