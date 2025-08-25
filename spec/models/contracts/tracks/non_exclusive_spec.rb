# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contracts::Track::NonExclusive, type: :model do
  subject(:contract) { described_class.new(valid_attributes) }

  let(:valid_attributes) do
    {
      terms_of_years: 2,
      delivers_mp3: true,
      delivers_wav: false,
      delivers_stems: true,
      distribution_copies: 1000,
      non_monetized_videos: 5,
      monetized_videos: 10,
      non_monetized_video_streams: 10000,
      monetized_video_streams: 50000,
      non_profitable_performances: 50,
      has_broadcasting_rights: true,
      radio_stations_allowed: 10,
      allow_profitable_performances: true
    }
  end

  describe "validations" do
    it "is valid with all numeric fields >= 0" do
      expect(contract).to be_valid
    end

    it "does not allow negative numbers" do
      numeric_fields = [
        :distribution_copies,
        :streams_allowed,
        :non_monetized_videos,
        :monetized_videos,
        :non_monetized_video_streams,
        :monetized_video_streams,
        :non_profitable_performances,
        :radio_stations_allowed
      ]

      numeric_fields.each do |field|
        contract.public_send("#{field}=", -1)
        expect(contract).not_to be_valid, "#{field} should not accept negative numbers"
        contract.public_send("#{field}=", 0)
        expect(contract).to be_valid
      end
    end
  end

  describe "boolean fields" do
    it "accepts true/false values for deliveries" do
      expect(contract.delivers_mp3).to eq(true)
      expect(contract.delivers_wav).to eq(false)
      expect(contract.delivers_stems).to eq(true)
      expect(contract.has_broadcasting_rights).to eq(true)
      expect(contract.allow_profitable_performances).to eq(true)
    end
  end
end
