# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::LegalTemplates do
  describe "::VERSIONS" do
    it "is frozen" do
      expect(described_class::VERSIONS).to be_frozen
    end
  end

  describe ".read_tos" do
    let(:path) { "templates/legal/terms_of_service.md" }

    it "reads the terms of service template" do
      allow(described_class).to receive(:read_template)
        .with(path)
        .and_return("tos content")

      result = described_class.read_tos

      expect(result).to eq("tos content")
    end
  end

  describe ".read_privacy" do
    let(:path) { "templates/legal/privacy_policy.md" }

    it "reads the privacy policy template" do
      allow(described_class).to receive(:read_template)
        .with(path)
        .and_return("privacy content")

      result = described_class.read_privacy

      expect(result).to eq("privacy content")
    end
  end

  describe ".read_cookies" do
    let(:path) { "templates/legal/cookies_policy.md" }

    it "reads the cookies policy template" do
      allow(described_class).to receive(:read_template)
        .with(path)
        .and_return("cookies content")

      result = described_class.read_cookies

      expect(result).to eq("cookies content")
    end
  end
end
