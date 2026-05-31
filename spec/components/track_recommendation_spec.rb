# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrackRecommendationComponent, type: :component do
  it "renders the recommendation group id and title" do
    rec = create(:track_recommendation, group: "A", tag_names: %w[a b])

    rendered = render_inline(described_class.new(track_recommendation: rec))

    expect(rendered).to have_css("#track-recommendation-A")
    expect(rendered).to have_text("A")
  end

  it "renders fallback icon when no image is attached" do
    rec = create(:track_recommendation, tag_names: %w[a b])

    rendered = render_inline(described_class.new(track_recommendation: rec))

    expect(rendered).to have_css("svg") # icon("photo-scan")
    expect(rendered).not_to have_css("img")
  end

  it "renders attached display image when present" do
    rec = create(:track_recommendation, tag_names: %w[a b])

    rec.display_image.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/recommendations/display_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )

    rendered = render_inline(described_class.new(track_recommendation: rec))

    expect(rendered).to have_css("img")
  end

  it "renders tag names from recommendation" do
    rec = create(:track_recommendation, tag_names: %w[a b c])

    rendered = render_inline(described_class.new(track_recommendation: rec))

    expect(rendered).to have_text("a")
    expect(rendered).to have_text("b")
    expect(rendered).to have_text("c")
  end

  it "passes tags into DynamicTagsComponent" do
    rec = create(:track_recommendation, tag_names: %w[x y])

    rendered = render_inline(described_class.new(track_recommendation: rec))

    expect(rendered).to have_text("x")
    expect(rendered).to have_text("y")
  end
end
