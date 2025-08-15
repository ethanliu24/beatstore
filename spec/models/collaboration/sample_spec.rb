# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration::Sample, type: :model do
  let(:track) { create(:track) }

  describe "validations" do
    it "is invalid without a name" do
      sample = described_class.new(name: "", track: track)
      expect(sample).not_to be_valid
      expect(sample.errors[:name]).to include("is required")
    end

    it "is valid with a name" do
      sample = described_class.new(name: "Song", track: track)
      expect(sample).to be_valid
    end
  end

  describe "defaults" do
    it "defaults name to empty string" do
      sample = described_class.new(track: track)
      expect(sample.name).to eq("")
    end
  end

  describe "associations" do
    it "belongs to a track" do
      assoc = described_class.reflect_on_association(:track)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "is invalid without a track" do
      sample = described_class.new(name: "Snare")
      expect(sample).not_to be_valid
      expect(sample.errors[:track]).to include("must exist")
    end
  end
end
