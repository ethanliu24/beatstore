# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Dropdown::TriggerComponent, type: :component do
  it "renders a button with the given id, classes and data with default values" do
    rendered = render_inline(described_class.new(
      id: "id",
      classes: "trigger",
      data: { custom: "data" })
    )

    expect(rendered).to have_selector(
      "button[id='id-dropdown-toggle']" \
      "[class='trigger']" \
      "[data-custom='data']" \
      "[data-dropdown-toggle='id']" \
      "[data-dropdown-placement='bottom-end']"
    )
  end

  it "overrides default data dropdown attributes" do
    rendered = render_inline(described_class.new(
      id: "id", data: { dropdown_placement: "top" })
    )

    expect(rendered).to have_selector(
      "button[id='id-dropdown-toggle']" \
      "[data-dropdown-toggle='id']" \
      "[data-dropdown-placement='top']"
    )
  end

  it "should not be able to override data dropdown toggle attribute" do
    rendered = render_inline(described_class.new(
      id: "id", data: { dropdown_toggle: "abcd" })
    )

    expect(rendered).to have_selector(
      "button[id='id-dropdown-toggle']" \
      "[data-dropdown-toggle='id']"
    )
  end
end
