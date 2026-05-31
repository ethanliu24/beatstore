# frozen_string_literal: true

require "rails_helper"

RSpec.describe DynamicTagsComponent, type: :component do
  let(:track) { create(:track) }

  def render_component(tags:, **kwargs)
    render_inline(described_class.new(tags:, resource: track, **kwargs))
  end

  it "renders all tag names" do
    create(:track_tag, track:, name: "Hip Hop")
    create(:track_tag, track:, name: "Trap")
    create(:track_tag, track:, name: "Drill")

    rendered = render_component(tags: track.tags)

    expect(rendered).to have_text("Hip Hop")
    expect(rendered).to have_text("Trap")
    expect(rendered).to have_text("Drill")
  end

  it "renders each tag in both main container and dropdown" do
    create(:track_tag, track:, name: "Hip Hop")
    create(:track_tag, track:, name: "Trap")

    rendered = render_component(tags: track.tags)

    # each tag appears twice (main + dropdown)
    expect(rendered.text.scan("Hip Hop").count).to eq(2)
    expect(rendered.text.scan("Trap").count).to eq(2)
  end

  it "renders tags in the order provided" do
    create(:track_tag, track:, name: "First")
    create(:track_tag, track:, name: "Second")
    create(:track_tag, track:, name: "Third")

    rendered = render_component(tags: track.tags)

    expect(rendered.text).to match(/First.*Second.*Third/m)
  end

  it "renders the responsive tag UI container" do
    rendered = render_component(tags: [])

    expect(rendered).to have_css("[data-controller='responsive-tag-ui']")
  end

  it "sets rerender_on_resize to true by default" do
    rendered = render_component(tags: [])

    container = rendered.css("[data-controller='responsive-tag-ui']").first

    expect(container["data-responsive-tag-ui-rerender-on-resize-value"]).to eq("true")
  end

  it "allows rerender_on_resize to be disabled" do
    rendered = render_component(
      tags: [],
      rerender_on_resize: false
    )

    container = rendered.css("[data-controller='responsive-tag-ui']").first

    expect(container["data-responsive-tag-ui-rerender-on-resize-value"]).to eq("false")
  end

  it "adds custom tag data attributes to main tags" do
    create(:track_tag, track:, name: "Hip Hop")

    rendered = render_component(
      tags: track.tags,
      tag_data: { test_id: "main-tag" }
    )

    expect(rendered.css("[data-test-id='main-tag']").count).to eq(1)
  end

  it "adds custom data attributes to dropdown tags" do
    create(:track_tag, track:, name: "Hip Hop")

    rendered = render_component(
      tags: track.tags,
      dropdown_tag_data: { test_id: "dropdown-tag" }
    )

    expect(rendered.css("[data-test-id='dropdown-tag']").count).to eq(1)
  end

  it "preserves responsive tag targets" do
    create(:track_tag, track:, name: "Hip Hop")

    rendered = render_component(tags: track.tags)

    expect(rendered.css("[data-responsive-tag-ui-target='tag']").count).to eq(1)
    expect(rendered.css("[data-responsive-tag-ui-target='dropdownTag']").count).to eq(1)
  end

  it "renders correctly with no tags" do
    rendered = render_component(tags: [])

    expect(rendered.css("[data-responsive-tag-ui-target='tag']").count).to eq(0)
    expect(rendered.css("[data-responsive-tag-ui-target='dropdownTag']").count).to eq(0)
  end
end
