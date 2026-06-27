# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recurring::MetricsCleanUpJob, type: :job do
  describe "#perform_now" do
    it "should delete all metrics that are ready to be pruned" do
      freeze_time do
        m1 = Metric.track(Metrics::Name::TEST)
        m2 = Metric.track(Metrics::Name::TEST)

        # ready to be pruned: current date has passed pruned_at
        now = Time.current
        m1.update!(prunes_at: now - 1.minutes)
        m2.update!(prunes_at: now - 1.minutes)

        expect(Metric.count).to eq(2)

        described_class.perform_now

        expect(Metric.count).to eq(0)
      end
    end

    it "should not delete any metrics that are not ready to be pruned" do
      freeze_time do
        # not ready to be pruned: current date has not passed pruned_at
        Metric.track(Metrics::Name::TEST)
        Metric.track(Metrics::Name::TEST)

        expect(Metric.count).to eq(2)

        described_class.perform_now

        expect(Metric.count).to eq(2)
      end
    end
  end

  describe "#perform_later" do
    it "should enqueue the job" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class)
    end
  end
end
