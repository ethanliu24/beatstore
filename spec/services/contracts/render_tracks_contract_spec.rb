# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contracts::RenderTracksContractService, type: :service do
  let(:track) { create(:track) }

  before do
    [
      { name: "A", role: Collaboration::Collaborator.roles[:producer], notes: "", profit_share: 1, publishing_share: 1 },
      { name: "B", role: Collaboration::Collaborator.roles[:producer], notes: "", profit_share: 1, publishing_share: 1 }
    ].each do |c|
      track.collaborators << Collaboration::Collaborator.new(**c)
    end
  end

  context "#call" do
    it "constructs free contract variables" do
      license = create(:license)
      contents = service(license:, track:).send(:construct_free_contract)

      expect(contents[:LICENSE_NAME]).to eq("Test")
      expect(contents[:TERMS_OF_YEARS]).to eq(1)
      expect(contents[:TRACK_CONTRIBUTOR_ALIASES]).to eq("prodethan, A, B")
      expect(contents[:STATE_PROVINCE_COUNTRY]).to eq("Ontario, Canada")
    end

    it "constructs non exclusive variables" do
      license = create(:non_exclusive_license)
      contents = service(license:, track:).send(:construct_non_exclusive_contract)

      expect(contents[:LICENSE_NAME]).to eq("Non Exclusive License")
      expect(contents[:PRODUCT_TITLE]).to eq("Track 1")
      expect(contents[:PRODUCT_PRICE]).to eq("$10.00 USD")
      expect(contents[:TERMS_OF_YEARS]).to eq(1)
      expect(contents[:DISTRIBUTE_COPIES]).to eq(10000)
      expect(contents[:AUDIO_STREAMS]).to eq(10000)
      expect(contents[:MONETIZED_MUSIC_VIDEOS]).to eq(1)
      expect(contents[:NON_MONETIZED_MUSIC_VIDEOS]).to eq(2)
      expect(contents[:HAS_BROADCASTING_RIGHT]).to eq(true)
      expect(contents[:NUMBER_OF_RADIO_STATIONS]).to eq(1)
      expect(contents[:INCLUDING_OR_NOT_INCLUDING_PERFOMANCES]).to eq("INCLUDING")
      expect(contents[:NON_PROFITABLE_PERFORMANCES_ALLOWED]).to eq(true)
      expect(contents[:SAMPLES]).to eq("NO THIRD PARTY SAMPLES USED ON THIS TRACK")
      expect(contents[:FILE_TYPE]).to eq("WAV")
    end

    it "renders the correct file type delivered" do
      l1 = create(:non_exclusive_license, contract_details: {
        delivers_mp3: true,
        delivers_wav: false,
        delivers_stems: false
      })

      contents = service(license: l1, track:).send(:construct_non_exclusive_contract)
      expect(contents[:FILE_TYPE]).to eq("MP3")

      l2 = create(:non_exclusive_license, title: "ASKFJLH", contract_details: {
        delivers_mp3: true,
        delivers_wav: true,
        delivers_stems: true
      })

      contents = service(license: l2, track:).send(:construct_non_exclusive_contract)
      expect(contents[:FILE_TYPE]).to eq("WAV")
    end

    it "renders the samples used on track" do
      track.samples << Collaboration::Sample.new(name: "Sample", artist: "Diddy", link: "")
      license = create(:non_exclusive_license)
      contents = service(license:, track:).send(:construct_non_exclusive_contract)

      expect(contents[:SAMPLES]).to eq("- Sample - Diddy")
    end
  end

  private

  def service(license:, track:)
    described_class.new(license:, track:)
  end
end
