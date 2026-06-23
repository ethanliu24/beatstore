# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metrics::BuildChartMetricsService, type: :model do
  let(:event_name) { Metrics::Name::TEST }
  let(:window) { WindowSize::ONE_DAY }
  let(:service) { described_class.new(event_name: event_name, window: window) }

  describe "#line_chart_metrics" do
    before do
      # Create various metrics
      create(:metric, event_name:, tags: { "env" => "prod", "browser" => "chrome" }, created_at: 2.hours.ago)
      create(:metric, event_name:, tags: { "env" => "dev", "browser" => "firefox" }, created_at: 3.hours.ago)
      create(:metric, event_name: Metrics::Name::STRIPE_ONE_TIME_PAYMENT, tags: { "env" => "prod" }, created_at: 1.hour.ago)
    end

    it "filters by event name and basic tags" do
      result = service.line_chart_metrics(tags: { "env" => "prod" })

      expect(result.values.sum).to eq(1)
    end

    it "further filters results using a block" do
      result = service.line_chart_metrics(tags: { "env" => "prod" }) do |tags|
        tags["browser"] == "chrome"
      end

      expect(result.values.sum).to eq(1)
    end

    it "returns 0 when no records match the criteria" do
      result = service.line_chart_metrics(tags: { "env" => "staging" })
      expect(result.values.sum).to eq(0)
    end
  end
end
