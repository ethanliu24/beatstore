# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMetricsByWindowService do
  include ActiveSupport::Testing::TimeHelpers

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
