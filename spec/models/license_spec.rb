# frozen_string_literal: true

require "rails_helper"

RSpec.describe License, type: :model do
  subject(:license) { build(:license) }

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should validate_presence_of(:price_cents) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:currency) }
    it { should validate_length_of(:currency).is_equal_to(3) }
    it { should validate_presence_of(:contract_type) }
  end

  describe "defaults" do
    it "sets USD as the default currency" do
      license = License.new
      expect(license.currency).to eq("USD")
    end

    it "sets default_for_new to false by default" do
      license = License.new
      expect(license.default_for_new).to eq(false)
    end
  end

  describe "contract type" do
    it "should allow valid contract types" do
      License.contract_types.each do |_, type|
        subject.contract_type = type
        expect(subject).to be_valid
      end
    end

    it "should reject invalid contract types" do
      expect {
        subject.contract_type = "invalid"
    }.to raise_error(ArgumentError)
    end
  end

  describe "monetization" do
    it "returns price as a Money object" do
      expect(subject.price_cents).to eq(1000)
      expect(subject.price.to_f).to eq(10.0)
    end
  end

  describe "#contract" do
    it "returns contract_details with indifferent access" do
      license = build(:license, contract_details: { "streams" => 1000 })
      expect(license.contract[:streams]).to eq(1000)
      expect(license.contract["streams"]).to eq(1000)
    end
  end
end
