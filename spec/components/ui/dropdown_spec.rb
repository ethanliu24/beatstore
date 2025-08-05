# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::DropdownComponent, type: :component do
  it "renders the given content and configs with a trigger button" do
    rendered = render_inline(described_class.new(
      id: "tracks", classes: "track", data: { controller: "tracks" }
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

    expect(rendered).to have_selector(
      "div[id='tracks'][class='dropdown hidden track'][data-controller='tracks']"
    )
    expect(rendered).to have_selector(
      "button[id='tracks-dropdown-toggle']",
      text: "Tracks Dropdown"
    )
    expect(rendered).to have_selector(
      "div.content",
      text: "Dropdown Content",
      count: 2
    )
  end
end
