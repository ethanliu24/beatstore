# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::PlayableCoverPhoto, type: :component do
  let(:track) { create(:track) }

  it "renders the cover photo if one is attached" do
    rendered = render_inline(described_class.new(track:, queue_scope: "spec", size: 6))

    expect(rendered).to have_css("img.cover-photo", count: 1)
    expect(rendered).to have_css("[style*='width: 6rem;'][style*='height: 6rem;']", count: 1)
  end

  it "renders an icon if cover photo is not attached" do
    track.cover_photo.purge
    rendered = render_inline(described_class.new(track:, queue_scope: "spec", size: 8))

    expect(rendered).to have_css("svg.cover-photo", count: 1)
    expect(rendered).to have_css("[style*='width: 8rem;'][style*='height: 8rem;']", count: 1)
  end

  it "allows dynamic unit" do
    rendered = render_inline(described_class.new(track:, queue_scope: "spec", size: 6, unit: "px"))

    expect(rendered).to have_css("img.cover-photo", count: 1)
    expect(rendered).to have_css("[style*='width: 6px;'][style*='height: 6px;']", count: 1)
  end

  it "renders play buttons" do
    rendered = render_inline(described_class.new(track:, queue_scope: "spec", size: 8))

    expect(rendered).to have_css("svg", count: 2)
  end
end
