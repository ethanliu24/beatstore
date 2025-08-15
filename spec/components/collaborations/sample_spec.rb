# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration::SampleComponent, type: :component do
  let(:sample) { instance_double("Collaboration::Sample", name: "Piano Loop", artist: nil, link: nil) }

  context "when artist is blank" do
    it "renders the name only" do
      rendered = render_inline(described_class.new(sample: sample))

      expect(rendered).to have_content("Piano Loop")
      expect(rendered.text).not_to have_content("-")
    end
  end

  context "when artist is present" do
    let(:sample) { instance_double("Collaboration::Sample", name: "Piano Loop", artist: "John Doe", link: nil) }

    it "renders name and artist with a dash" do
      render_inline(described_class.new(sample: sample))

      expect(rendered_content).to include("Piano Loop - John Doe")
    end
  end

  context "when link is blank" do
    it "does not render the external link icon" do
      render_inline(described_class.new(sample: sample))

      expect(rendered_content).not_to have_css(".link-btn")
      expect(rendered_content).not_to have_link
    end
  end

  context "when link is present" do
    let(:sample) { create(:sample) }

    it "renders an external link icon with correct attributes" do
      rendered = render_inline(described_class.new(sample:))
      expect(rendered).to have_css(".link-btn")
    end
  end
end
