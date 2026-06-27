# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recurring::MetricsCleanUpJob, type: :job do
  describe "#perform_now" do
    it "should delete all metrics that are ready to be pruned" do
      freeze_time do
        # ready to be pruned: current date has passed pruned_at
        m1 = Metric.track(Metrics::Name::TEST)
        m2 = Metric.track(Metrics::Name::TEST)

        now = Time.current
        m1.update!(prunes_at: now - 1.minutes)
        m2.update!(prunes_at: now - 1.minutes)

        expect {
          described_class.perform_now
        }.to change(Metric, :count).by(-2 + 1)

        metric = Metric.last
        expect(metric.event_name).to eq(Metrics::Name::METRICS_CLEAN_UP_FINISHED)
        expect(metric.tags).to eq({ "num_deleted" => 2 })
      end
    end

    it "should not delete any metrics that are not ready to be pruned" do
      freeze_time do
        # not ready to be pruned: current date has not passed pruned_at
        Metric.track(Metrics::Name::TEST)
        Metric.track(Metrics::Name::TEST)

        expect {
          described_class.perform_now
        }.to change(Metric, :count).by(1)

        metric = Metric.last
        expect(metric.event_name).to eq(Metrics::Name::METRICS_CLEAN_UP_FINISHED)
        expect(metric.tags).to eq({ "num_deleted" => 0 })
      end
    end

    it "should not delete metrics that should never be pruned" do
      freeze_time do
        # never be pruned: prunes_at = nil
        Metric.track(Metrics::Name::TEST, prune: false)
        Metric.track(Metrics::Name::TEST, prune: false)

        expect {
          described_class.perform_now
        }.to change(Metric, :count).by(1)

        metric = Metric.last
        expect(metric.event_name).to eq(Metrics::Name::METRICS_CLEAN_UP_FINISHED)
        expect(metric.tags).to eq({ "num_deleted" => 0 })
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
