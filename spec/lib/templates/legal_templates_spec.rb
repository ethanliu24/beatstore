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
end
