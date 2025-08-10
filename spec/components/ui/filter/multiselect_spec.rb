# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Filter::MultiselectComponent, type: :component do
  let(:options) { [ "Option A", "Option B" ] }
  let(:values)  { [ "a", "b" ] }

  it "renders checkboxes with labels" do
    render_inline(
      described_class.new(
        label: "Test",
        query: :category,
        options: options,
        values: values
      )
    )

    # Ensure both checkboxes exist
    expect(page).to have_css("input[type='checkbox'][value='a']")
    expect(page).to have_css("input[type='checkbox'][value='b']")

    # Ensure both labels exist
    expect(page).to have_text("Option A")
    expect(page).to have_text("Option B")
  end

  it "applies custom container data attributes" do
    render_inline(
      described_class.new(
        label: "Test",
        query: :category,
        options: options,
        values: values,
        container_data: { controller: "filters" }
      )
    )

    expect(page).to have_css("ul[data-controller='filters']")
  end

  it "does not render when render? is false" do
    result = render_inline(
      described_class.new(
        label: "Test",
        query: :category,
        options: options,
        values: values,
        render: false
      )
    )

    expect(result.to_html.strip).to eq("")
  end
end
