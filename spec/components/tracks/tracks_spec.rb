# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::TrackComponent, type: :component do
  let!(:track) { create(:track) }
  let!(:tag) { create(:track_tag, track:) }
  let!(:current_user) { create(:user) }
  subject(:rendered) { render_inline(described_class.new(track:, current_user:)) }

  it "renders the neccessary track fields" do
    expect(rendered.text).to include("Track 1")
    expect(rendered.text).to include("C MAJOR")
    expect(rendered.text).to include("111")
    expect(rendered.text).to include("Trap")
  end

  it "renders the cover photo if one is attached" do
    expect(rendered).to have_css("img.cover-photo")
    expect(rendered.css("img.cover-photo").count).to eq(1)
  end

  it "renders an icon if cover photo is not attached" do
    track.cover_photo.purge
    track.reload
    rendered = render_inline(Tracks::TrackComponent.new(track:, current_user:))

    expect(rendered).to have_css("svg.cover-photo")
    expect(rendered.css("svg.cover-photo").count).to eq(1)
  end

  # it "renders all tags" do
  #   expect(rendered.text).to include("#lebron")
  # end

  it "renders a dropdown" do
    expect(rendered).to have_css("#customer-track-more-dropdown")
    expect(rendered).to have_css("#track_more_track_#{track.id}")
    expect(rendered.css("div.dropdown").count).to eq(1)
    expect(rendered.css("li.dropdown-item").count).to eq(8)
  end

  # TODO test shopping cart
end
