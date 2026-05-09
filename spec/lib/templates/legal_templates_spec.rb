# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::LegalTemplates do
  describe "::VERSIONS" do
    it "is frozen" do
      expect(described_class::VERSIONS).to be_frozen
    end
  end

  describe ".read_tos" do
    subject(:content) { described_class.read_tos }

    it "loads the terms of service template" do
      expected_content = File.read(
        Rails.root.join("templates/legal/terms_of_service.md")
      )

      expect(content).to eq(expected_content)
      expect(content).to be_present
    end
  end

  describe ".read_privacy" do
    subject(:content) { described_class.read_privacy }

    it "loads the privacy policy template" do
      expected_content = File.read(
        Rails.root.join("templates/legal/privacy_policy.md")
      )

      expect(content).to eq(expected_content)
      expect(content).to be_present
    end
  end

  describe ".read_cookies" do
    subject(:content) { described_class.read_cookies }

    it "loads the cookies policy template" do
      expected_content = File.read(
        Rails.root.join("templates/legal/cookies_policy.md")
      )

      expect(content).to eq(expected_content)
      expect(content).to be_present
    end
  end

  describe described_class::Versioning do
    let(:versioning) do
      described_class.new(
        tos: "1.0",
        privacy: "2.0",
        cookies: "3.0"
      )
    end

    describe "#initialize" do
      it "sets attributes correctly" do
        expect(versioning.tos).to eq("1.0")
        expect(versioning.privacy).to eq("2.0")
        expect(versioning.cookies).to eq("3.0")
      end
    end

    describe "#serialize" do
      it "serializes versioning to JSON" do
        json = versioning.serialize(versioning)

        expect(JSON.parse(json)).to eq(
          {
            "tos" => "1.0",
            "privacy" => "2.0",
            "cookies" => "3.0"
          }
        )
      end
    end

    describe "#deserialize" do
      it "rebuilds a Versioning object from JSON hash" do
        json = versioning.serialize(versioning)
        parsed = JSON.parse(json).symbolize_keys

        result = described_class.deserialize(parsed)

        expect(result.tos).to eq("1.0")
        expect(result.privacy).to eq("2.0")
        expect(result.cookies).to eq("3.0")
      end
    end
  end
end
