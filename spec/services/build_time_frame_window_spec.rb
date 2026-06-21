# frozen_string_literal: true

require "rails_helper"

RSpec.describe BuildTimeFrameWindowService do
  include ActiveSupport::Testing::TimeHelpers

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
  end

  describe ".group_metrics_by_time" do
    let(:relation) { double("relation") }

    it "groups by minute for ONE_HOUR" do
      expect(relation).to receive(:group_by_minute).with(:created_at)

      described_class.group_metrics_by_time(
        relation,
        window: WindowSize::ONE_HOUR,
        column: :created_at
      )
    end

    it "groups by hour for short windows" do
      [
        WindowSize::TWELVE_HOURS,
        WindowSize::ONE_DAY,
        WindowSize::THREE_DAYS
      ].each do |window|
        expect(relation).to receive(:group_by_hour).with(:created_at)

        described_class.group_metrics_by_time(
          relation,
          window: window,
          column: :created_at
        )
      end
    end

    it "groups by day for week/month windows" do
      [
        WindowSize::ONE_WEEK,
        WindowSize::ONE_MONTH
      ].each do |window|
        expect(relation).to receive(:group_by_day).with(:created_at)

        described_class.group_metrics_by_time(
          relation,
          window: window,
          column: :created_at
        )
      end
    end

    it "groups by week for long windows" do
      [
        WindowSize::SIX_MONTHS,
        WindowSize::ONE_YEAR
      ].each do |window|
        expect(relation).to receive(:group_by_week).with(:created_at)

        described_class.group_metrics_by_time(
          relation,
          window: window,
          column: :created_at
        )
      end
    end

    it "defaults to grouping by day" do
      expect(relation).to receive(:group_by_day).with(:created_at)

      described_class.group_metrics_by_time(
        relation,
        window: nil,
        column: :created_at
      )
    end
  end
end
