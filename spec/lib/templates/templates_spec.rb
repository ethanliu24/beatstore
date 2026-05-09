# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::Templates do
  describe "#read_contract_templates" do
    let(:free_path) do
      "templates/contracts/tracks/free.md"
    end

    let(:non_exclusive_path) do
      "templates/contracts/tracks/non_exclusive.md"
    end

    before do
      allow(License).to receive(:contract_types).and_return(
        {
          free: "free",
          non_exclusive: "non_exclusive"
        }
      )
    end

    context "when all template files exist" do
      before do
        allow(File).to receive(:exist?).with(free_path).and_return(true)
        allow(File).to receive(:exist?).with(non_exclusive_path).and_return(true)

        allow(File).to receive(:read).with(free_path).and_return("free template")
        allow(File).to receive(:read).with(non_exclusive_path).and_return("non exclusive template")
      end

      it "returns all contract templates" do
        result = described_class.read_contract_templates

        expect(result).to eq(
          {
            "free" => "free template",
            "non_exclusive" => "non exclusive template"
          }.with_indifferent_access
        )
      end
    end

    context "when template files do not exist" do
      before do
        allow(File).to receive(:exist?).with(free_path).and_return(false)
        allow(File).to receive(:exist?).with(non_exclusive_path).and_return(false)
      end

      it "returns empty strings for missing templates" do
        result = described_class.read_contract_templates

        expect(File).not_to receive(:read)

        expect(result).to eq(
          {
            "free" => "",
            "non_exclusive" => ""
          }.with_indifferent_access
        )
      end
    end

    context "when only one template file exists" do
      before do
        allow(File).to receive(:exist?).with(free_path).and_return(true)
        allow(File).to receive(:exist?).with(non_exclusive_path).and_return(false)

        allow(File).to receive(:read).with(free_path).and_return("free template")
      end

      it "returns content for existing template and empty string for missing one" do
        result = described_class.read_contract_templates

        expect(result).to eq(
          {
            "free" => "free template",
            "non_exclusive" => ""
          }.with_indifferent_access
        )
      end
    end
  end
end
