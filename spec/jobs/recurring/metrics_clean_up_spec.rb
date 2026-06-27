# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recurring::MetricsCleanUpJob, type: :job do
  describe "#perform_now" do
    it "should call metrics clean up service" do
      allow(CleanUps::CleanUpMetricsService).to receive(:call)

      described_class.perform_now
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
