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
  end
end
