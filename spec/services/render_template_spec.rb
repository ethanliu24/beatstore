# frozen_string_literal: true

require "rails_helper"

RSpec.describe RenderTemplateService, type: :service do
  context "#call" do
    it "should replace the placeholders with actual contents" do
      template = "Name: {{ NAME }}"
      contents = { "NAME": "Diddy" }
      result = call_service(template:, contents:)

      expect(result).to eq("Name: Diddy")
    end

    it "should string cast contents that aren't strings" do
      template = "Count: {{ COUNT }}"
      contents = { "COUNT": 5 }
      result = call_service(template:, contents:)

      expect(result).to eq("Count: 5")
    end

    it "should not change anything if no placeholders match" do
      template = "Name: {{ NAME }}"
      contents = { "INVALID": "Diddy" }
      result = call_service(template:, contents:)

      expect(result).to eq("Name: {{ NAME }}")
    end

    it "should only replace the placeholders' contents that are passed in" do
      template = "Name: {{ NAME }}, Price: ${{ PRICE }}"
      contents = {
        "NAME": "Track 1",
        "PRICE": 19.99,
        "INVALID": "Diddy"
      }
      result = call_service(template:, contents:)

      expect(result).to eq("Name: Track 1, Price: $19.99")
    end

    private

    def call_service(template:, contents:)
      RenderTemplateService.new(template:, contents:).call
    end
  end
end
