# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuickStat do
  let(:relation) { double("relation") }
  let(:window) { 7.days }

  describe "#icon" do
    it "returns correct icon for known stat types" do
      stats = described_class.new(name: :sales, relation: relation, window: window)
      expect(stats.icon).to eq("receipt-dollar")
    end

    it "returns default icon for unknown stat types" do
      stats = described_class.new(name: :unknown, relation: relation, window: window)
      expect(stats.icon).to eq("analyze")
    end
  end

  describe "#cum_stat" do
    it "returns count for non-sales stats" do
      allow(relation).to receive(:count).and_return(42)

      stats = described_class.new(name: :comments, relation: relation, window: window)

      expect(stats.cum_stat).to eq(42)
    end

    it "returns formatted money string for sales" do
      allow(relation).to receive(:sum).with(:amount_cents).and_return(1050)

      stats = described_class.new(name: :sales, relation: relation, window: window)

      expect(stats.cum_stat).to be_a(String)
    end

    it "handles nil sum gracefully" do
      allow(relation).to receive(:sum).with(:amount_cents).and_return(nil)

      stats = described_class.new(name: :sales, relation: relation, window: window)

      expect(stats.cum_stat).to eq(Money.new(0).format)
    end
  end

  describe "#chron_stat" do
    let(:grouped_relation) { double("grouped_relation") }
    let(:stats) { described_class.new(name: name, relation: relation, window: window) }

    before do
      allow(GroupMetricsByWindowService).to receive(:group_metrics_by_time).and_return(grouped_relation)
    end

    context "for non-sales stats" do
      let(:name) { :comments }

      it "returns grouped counts" do
        allow(grouped_relation).to receive(:count).and_return({ Date.today => 3, Date.yesterday => 5 })

        expect(stats.chron_stat).to eq(grouped_relation.count)
      end
    end

    context "for sales stats" do
      let(:name) { :sales }

      it "returns grouped money sums in dollars" do
        allow(grouped_relation).to receive(:sum).with(:amount_cents)
          .and_return({ Date.today => 150, Date.yesterday => 250 })

        expect(stats.chron_stat).to eq(
          {
            Date.today => 1.5,
            Date.yesterday => 2.5
          }
        )
      end
    end
  end
end
