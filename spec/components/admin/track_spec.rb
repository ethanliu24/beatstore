# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::TrackComponent, type: :component do
  let!(:track) { create(:track_with_files) }
  subject(:rendered) { render_inline(described_class.new(track:)) }

  it "renders the neccessary track fields" do
    expect(rendered.text).to have_content("Track with files")
    expect(rendered.text).to have_content("C MAJOR")
    expect(rendered.text).to have_content("111")
    expect(rendered.text).to have_content("Hip Hop")
    expect(rendered.text).to have_content("Public")
    expect(rendered.text).not_to have_content("Private")
    expect(rendered).to have_css("p", text: "0", count: 3)
    expect(rendered).to have_css("#track_#{track.id}")
  end

  it "renders a dropdown" do
    expect(rendered).to have_css("#admin_track_more_track_#{track.id}-dropdown-toggle")
    expect(rendered).to have_css("#admin_track_more_track_#{track.id}")
    expect(rendered).to have_css("button[data-dropdown-toggle='admin_track_more_track_#{track.id}']", count: 1)
    expect(rendered).to have_css("div.dropdown", count: 1)
    expect(rendered).to have_css("li.dropdown-item", count: 4)
  end
end
