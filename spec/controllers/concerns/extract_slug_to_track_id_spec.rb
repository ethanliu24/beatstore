# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExtractSlugToTrackId, type: :model do
  let(:dummy_class) do
    Class.new do
      include ExtractSlugToTrackId
    end
  end

  subject(:instance) { dummy_class.new }

  describe "#extract_track_id" do
    it "returns the numeric id from a slug with format title-id" do
      expect(instance.extract_track_id("lofi-123")).to eq(123)
    end

    it "returns the last part even if there are multiple hyphens" do
      expect(instance.extract_track_id("this-is-a-test-42")).to eq(42)
    end

    it "returns -1 if slug is blank" do
      expect(instance.extract_track_id(nil)).to eq(-1)
      expect(instance.extract_track_id("")).to eq(-1)
    end

    it "returns 0 if last part of slug is not numerical" do
      expect(instance.extract_track_id("slug")).to eq(0)
    end
  end
end
