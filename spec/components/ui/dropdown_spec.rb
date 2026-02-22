# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::DropdownComponent, type: :component do
  it "renders the given content and configs with a trigger button" do
    rendered = render_inline(described_class.new(
      id: "tracks", classes: "track", data: { tracks: "tracks" }
    )) do |component|
      component.with_trigger_button(
        id: "tracks",
        classes: "btn-primary",
        data: { controller: "track" }
      ) do
        "Tracks Dropdown"
      end
      component.with_section do
        "<div class='content'>Dropdown Content</div>".html_safe
      end
      component.with_section do
        "<div class='content'>Dropdown Content</div>".html_safe
      end
    end

    expect(rendered).to have_selector("button", text: "Tracks Dropdown")
    expect(rendered).to have_selector("div[data-controller='dropdown-manager']")
    expect(rendered).to have_selector(
      "div[id='tracks'][class='dropdown hidden absolute w-max transparent-scrollbar-background track'][data-tracks='tracks']"
    )
    expect(rendered).to have_selector(
      "div.content",
      text: "Dropdown Content",
      count: 2
    )
  end

  it "renders the correct position and trigger action" do
    rendered = render_inline(described_class.new(
      id: "tracks",
      position: "left",
      trigger_action: "hover",
      classes: "track",
      data: { controller: "tracks" }
    )) do |component|
      component.with_trigger_button(id: "tracks", classes: "btn-primary") do
        "Dropdown"
      end
    end

    expect(rendered).to have_selector(
      "div[data-dropdown-manager-position-value='left'][data-dropdown-manager-trigger-action-value='hover']"
    )
  end

  it "defaults to the default position and trigger action if not provided" do
    rendered = render_inline(described_class.new(
      id: "tracks",
      classes: "track",
      data: { controller: "tracks" }
    )) do |component|
      component.with_trigger_button(id: "tracks", classes: "btn-primary") do
        "Dropdown"
      end
    end

    expect(rendered).to have_selector(
      "div[data-dropdown-manager-position-value='bottom-end'][data-dropdown-manager-trigger-action-value='click']"
    )
  end
end
