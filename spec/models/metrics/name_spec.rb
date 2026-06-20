# frozen_string_literal: true

require "rails_helper"

RSpec.describe Metrics::Name do
  describe ".is_defined?" do
    it "returns true for defined metric names" do
      expect(described_class.is_defined?(Metrics::Name::TEST)).to be true
    end

    it "returns false for unknown metric names" do
      expect(described_class.is_defined?("unknown_metric")).to be false
    end

    it "is false for nil" do
      expect(described_class.is_defined?(nil)).to be false
    end

    it "works with string constants" do
      expect(described_class.is_defined?("test")).to be true
    end
  end

  describe ".defined_names (via behavior)" do
    it "includes TEST constant in the defined set" do
      names = Metrics::Name.send(:defined_names)

      expect(names).to include("test")
    end
  end
end
