# frozen_string_literal: true

require "rails_helper"

RSpec.describe WindowSize, type: :model do
  describe ".time_frame" do
    around do |example|
      travel_to(Time.zone.local(2024, 1, 1, 12, 0, 0)) do
        example.run
      end
    end

    it "returns 1 hour ago for ONE_HOUR" do
      expect(described_class.time_frame(WindowSize::ONE_HOUR))
        .to eq(1.hour.ago)
    end

    it "returns 12 hours ago for TWELVE_HOURS" do
      expect(described_class.time_frame(WindowSize::TWELVE_HOURS))
        .to eq(12.hours.ago)
    end

    it "returns 1 day ago for ONE_DAY" do
      expect(described_class.time_frame(WindowSize::ONE_DAY))
        .to eq(1.day.ago)
    end

    it "returns 3 days ago for THREE_DAYS" do
      expect(described_class.time_frame(WindowSize::THREE_DAYS))
        .to eq(3.days.ago)
    end

    it "returns 1 week ago for ONE_WEEK" do
      expect(described_class.time_frame(WindowSize::ONE_WEEK))
        .to eq(1.week.ago)
    end

    it "returns 1 month ago for ONE_MONTH" do
      expect(described_class.time_frame(WindowSize::ONE_MONTH))
        .to eq(1.month.ago)
    end

    it "returns 6 months ago for SIX_MONTHS" do
      expect(described_class.time_frame(WindowSize::SIX_MONTHS))
        .to eq(6.months.ago)
    end

    it "returns 1 year ago for ONE_YEAR" do
      expect(described_class.time_frame(WindowSize::ONE_YEAR))
        .to eq(1.year.ago)
    end

    it "raises an error if window is not defined" do
      expect { described_class.time_frame("unknown") }
        .to raise_error(ArgumentError, "unrecognized window size: unknown")
    end
  end
end
