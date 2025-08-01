# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::ListComponent, type: :component do
  let!(:current_user) { create(:user) }
  subject(:rendered) { render_inline(described_class.new(track:, current_user:)) }

  it "renders all tracks in the given list" do
    tracks = create_list(:track, 3)
    rendered = render_inline(described_class.new(tracks: tracks, current_user:))

    expect(rendered.css("div.track").count).to eq(3)
  end

  it "renders a text that indicates no tracks if there are none" do
    rendered = render_inline(described_class.new(tracks: [], current_user:))

    expect(rendered).to have_css("p#no-tracks-message")
  end
end
