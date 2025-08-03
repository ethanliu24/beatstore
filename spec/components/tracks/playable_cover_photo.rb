# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::PlayableCoverPhoto, type: :component do
  let(:track) { create(:track) }

  it "renders the cover photo if one is attached" do
    rendered = render_inline(described_class.new(track:, size: 6))

    expect(rendered).to have_css("img.cover-photo", count: 1)
    expect(rendered).to have_css("div.w-6.h-6.aspect-square", count: 1)
  end

  it "renders an icon if cover photo is not attached" do
    track.cover_photo.purge
    rendered = render_inline(described_class.new(track:, size: 8))

    expect(rendered).to have_css("svg.cover-photo", count: 1)
    expect(rendered).to have_css("div.w-8.h-8.aspect-square", count: 1)
  end

  it "renders a play button" do
    rendered = render_inline(described_class.new(track:, size: 8))

    expect(rendered).to have_css("svg.play-btn", count: 1)
  end
end
