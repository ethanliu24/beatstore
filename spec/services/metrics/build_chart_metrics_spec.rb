# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metrics::BuildChartMetricsService, type: :model do
  let(:event_name) { Metrics::Name::TEST }
  let(:other_event) { Metrics::Name::STRIPE_ONE_TIME_PAYMENT }
  let(:window) { WindowSize::ONE_DAY }
  let(:service) { described_class.new(event_name: event_name, window: window) }

  describe "#line_chart_metrics" do
    before do
      # Create various metrics
      create(:metric, event_name:, tags: { "env" => "prod", "browser" => "chrome" }, created_at: 2.hours.ago)
      create(:metric, event_name:, tags: { "env" => "dev", "browser" => "firefox" }, created_at: 3.hours.ago)
      create(:metric, event_name: other_event, tags: { "env" => "prod" }, created_at: 1.hour.ago)
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

  describe "#pie_chart_metrics" do
    before do
      create(:metric, event_name: event_name, tags: { "browser" => "chrome", "env" => "prod" }, created_at: 1.hour.ago)
      create(:metric, event_name: event_name, tags: { "browser" => "chrome", "env" => "prod" }, created_at: 2.hours.ago)
      create(:metric, event_name: event_name, tags: { "browser" => "firefox", "env" => "prod" }, created_at: 3.hours.ago)
      create(:metric, event_name: other_event, tags: { "browser" => "safari" }, created_at: 1.hour.ago)
    end

    it "groups by a key inside the tags JSONB column" do
      result = service.pie_chart_metrics(group: :browser, tags: { "env" => "prod" })

      expect(result).to eq({ "chrome" => 2, "firefox" => 1 })
    end

    it "applies the tag_filter block before grouping" do
      result = service.pie_chart_metrics(group: :browser, tags: { "env" => "prod" }) do |tags|
        tags["browser"] == "chrome"
      end

      expect(result).to eq({ "chrome" => 2 })
    end

    it "returns nothing if group key doesn't exist" do
      result = service.pie_chart_metrics(group: :undefined)
      expect(result).to eq({})
    end
  end

  describe "#query_relation" do
    subject(:relation) { service.send(:query_relation, tags: tags, &tag_filter) }

    let(:service) { described_class.new(event_name: Metrics::Name::TEST, window:) }
    let(:window) { WindowSize::ONE_DAY }

    let(:tags) { {} }
    let(:tag_filter) { nil }

    let(:now) { Time.zone.parse("2026-01-01 12:00:00") }

    it "returns only metrics for the event name" do
      matching = track(tags: { a: 1 })
      Metric.track(Metrics::Name::ORDER_FULFILLMENT_RESULT)

      expect(relation).to contain_exactly(matching)
    end

    it "filters by created_at window" do
      matching = track
      travel_to(2.weeks.ago) { track } # outside window

      expect(relation).to contain_exactly(matching)
    end

    it "includes records with nil prunes_at" do
      matching = track(prune: false)

      expect(relation).to include(matching)
    end

    it "includes records with future prunes_at" do
      matching = track(prunes_after: 1.hour)

      expect(relation).to include(matching)
    end

    it "excludes expired records" do
      track(prunes_after: -1.hour)

      expect(relation).to be_empty
    end

    context "with tag hash filter" do
      let(:tags) { { country: "CA" } }

      it "matches JSONB containment" do
        matching = track(tags: { country: "CA", plan: "pro" })
        track(tags: { country: "US" })

        expect(relation).to contain_exactly(matching)
      end
    end

    context "with ruby tag_filter" do
      let(:tag_filter) { ->(tags) { tags["plan"] == "pro" } }

      it "filters in Ruby after DB query" do
        matching = track(tags: { plan: "pro" })
        track(tags: { plan: "free" })

        expect(relation).to contain_exactly(matching)
      end
    end

    private

    def track(**opts)
      Metric.track(Metrics::Name::TEST, **opts)
    end
  end
end
