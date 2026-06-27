# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metric, type: :model do
  let(:event_name) { Metrics::Name::TEST }

  it { should validate_presence_of(:event_name) }
  it { should validate_presence_of(:created_at) }

  context "validation" do
    let(:created_at) { Time.current }
    let(:prunes_at) { created_at + 1.minutes }

    it "should accept defined names" do
      metric = Metric.new(event_name:, tags: {}, prunes_at:, created_at:)

      expect(metric.valid?).to eq(true)
    end

    it "should not accept undefined names" do
      metric = Metric.new(event_name: "undefined", tags: {}, prunes_at:, created_at:)

      expect(metric.valid?).to eq(false)
      expect(metric.errors[:event_name]).to include("is not defined - add in Metric::Names")
    end

    it "should validate that tags is a hash" do
      metric = Metric.new(event_name:, tags: 1, prunes_at:, created_at:)

      expect(metric.valid?).to eq(false)
      expect(metric.errors[:tags]).to include("must be a hash")
    end
  end

  describe ".track" do
    it "should create a new Metric record with default params" do
      expect {
        Metric.track(event_name)
      }.to change(Metric, :count).by(1)

      metric = Metric.last

      expect(metric.event_name).to eq(event_name)
      expect(metric.tags).to eq({})
      expect(metric.created_at).not_to eq(nil)
      expect(metric.prunes_at).to eq(metric.created_at + Metric::DEFAULT_PRUNES_AFTER)
    end

    it "should set tags to what's provided" do
      expect {
        Metric.track(event_name, tags: { test: true })
      }.to change(Metric, :count).by(1)

      metric = Metric.last

      expect(metric.tags).to eq({ "test" => true })
    end

    it "should set prunes_at according to the time provided if prune is true" do
      prunes_after = 1.minutes

      expect {
        Metric.track(event_name, prune: true, prunes_after:)
      }.to change(Metric, :count).by(1)

      metric = Metric.last

      expect(metric.prunes_at).to eq(metric.created_at + prunes_after)
    end

    it "should set prunes_at to nil if prune is false, even if prunes_after is provided" do
      prunes_after = 1.minutes

      expect {
        Metric.track(event_name, prune: false, prunes_after:)
      }.to change(Metric, :count).by(1)

      metric = Metric.last

      expect(metric.prunes_at).to eq(nil)
    end

    it "should raise an error if validation fails" do
      expect {
        Metric.track("undefined")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe ".query" do
    let(:event_name) { Metrics::Name::TEST }
    let(:window) { WindowSize::ONE_DAY }
    let(:tags) { {} }
    let(:tag_filter) { nil }
    let(:now) { Time.current }

    it "returns only metrics for the event name" do
      matching = Metric.track(event_name)
      Metric.track(Metrics::Name::ORDER_FULFILLMENT_RESULT)
      relation = Metric.query(event_name, window:)

      expect(relation).to contain_exactly(matching)
    end

    it "filters by created_at window" do
      matching = Metric.track(event_name)
      travel_to(2.weeks.ago) { Metric.track(event_name) } # outside window
      relation = Metric.query(event_name, window:)

      expect(relation).to contain_exactly(matching)
    end

    it "includes records with nil prunes_at" do
      matching = Metric.track(event_name, prune: false)
      relation = Metric.query(event_name, window:)

      expect(relation).to include(matching)
    end

    it "includes records with future prunes_at" do
      matching = Metric.track(event_name, prunes_after: 1.hour)
      relation = Metric.query(event_name, window:)

      expect(relation).to include(matching)
    end

    it "excludes expired records" do
      Metric.track(event_name, prunes_after: -1.hour)
      relation = Metric.query(event_name, window:)

      expect(relation).to be_empty
    end

    context "with tags hash filter" do
      let(:tags) { { country: "CA" } }

      it "matches JSONB containment" do
        matching = Metric.track(event_name, tags: { country: "CA" })
        Metric.track(event_name, tags: { country: "US" })
        relation = Metric.query(event_name, window:, tags: { country: "CA" })

        expect(relation).to contain_exactly(matching)
      end
    end

    context "with &tag_filter" do
      let(:tag_filter) { ->(tags) { tags["count"] >= 5 } }

      it "filters in Ruby after DB query" do
        matching = Metric.track(event_name, tags: { count: 10 })
        Metric.track(event_name, tags: { count: 2 })
        relation = Metric.query(event_name, window:) { |tag| tag["count"] >= 5 }

        expect(relation).to contain_exactly(matching)
      end
    end
  end
end
