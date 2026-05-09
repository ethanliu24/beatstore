# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::ContractTemplates do
  describe ".read_contract_templates" do
    subject(:templates) { described_class.read_contract_templates }

    it "loads the free contract template" do
      expect(templates["free"]).to be_present

      expected_content = File.read(
        Rails.root.join("templates/contracts/tracks/free.md")
      )

      expect(templates["free"]).to eq(expected_content)
    end

    it "loads the non-exclusive contract template" do
      expect(templates["non_exclusive"]).to be_present

      expected_content = File.read(
        Rails.root.join("templates/contracts/tracks/non_exclusive.md")
      )

      expect(templates["non_exclusive"]).to eq(expected_content)
    end

    it "returns an indifferent access hash" do
      expect(templates[:free]).to eq(templates["free"])
      expect(templates[:non_exclusive]).to eq(templates["non_exclusive"])
    end
  end
end
