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
      "[class='trigger']" \
      "[data-custom='data']"
    )
  end
end
