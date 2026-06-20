# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metric, type: :model do
  it { should validate_presence_of(:event_name) }
  it { should validate_presence_of(:prunes_at) }
  it { should validate_presence_of(:created_at) }

  context "validation" do
    let(:created_at) { Time.current }
    let(:prunes_at) { created_at + 1.minutes }

    it "should accept defined names" do
      metric = Metric.new(
        event_name: Metrics::Name::TEST,
        tags: {},
        prunes_at:,
        created_at:
      )

      expect(metric.valid?).to eq(true)
    end

    it "should not accept undefined names" do
      metric = Metric.new(
        event_name: "undefined",
        tags: {},
        prunes_at:,
        created_at:
      )

      expect(metric.valid?).to eq(false)
      expect(metric.errors[:event_name]).to include("is not defined - add in Metric::Names")
    end

    it "should validate that tags is a hash" do
      metric = Metric.new(
        event_name: Metrics::Name::TEST,
        tags: 1,
        prunes_at:,
        created_at:
      )

      expect(metric.valid?).to eq(false)
      expect(metric.errors[:tags]).to include("must be a hash")
    end
  end
end
