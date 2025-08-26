# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contracts::Track::Base, type: :model do
  subject(:contract) { described_class.new(valid_attributes) }

  let(:valid_attributes) do
    {
      terms_of_years: 3,
      delivers_mp3: true,
      delivers_wav: false,
      delivers_stems: true
    }
  end

  describe "validations" do
    it "is valid with all required attributes" do
      expect(contract).to be_valid
    end

    it "requires terms_of_years to be an integer greater than 0" do
      contract.terms_of_years = 0
      expect(contract).not_to be_valid
      expect(contract.errors[:terms_of_years]).to include("must be greater than 0")

      contract.terms_of_years = -5
      expect(contract).not_to be_valid

      contract.terms_of_years = 2
      expect(contract).to be_valid
    end
  end

  describe "boolean fields" do
    it "accepts true/false values" do
      expect(contract.delivers_mp3).to eq(true)
      expect(contract.delivers_wav).to eq(false)
      expect(contract.delivers_stems).to eq(true)
    end
  end
end
