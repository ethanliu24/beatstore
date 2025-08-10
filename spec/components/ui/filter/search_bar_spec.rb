# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Filter::SearchBarComponent, type: :component do
  let(:mock_form) do
    double("form", text_field: '<input type="text" name="q" placeholder="Search here...">'.html_safe)
  end

  it "renders a search input with placeholder" do
    render_inline(
      described_class.new(
        form: mock_form,
        query: :q,
        placeholder: "Search here..."
      )
    )

    expect(page).to have_css("input[placeholder='Search here...']")
    expect(page).to have_css("svg") # search icon
  end

  it "renders submit and clear buttons when provided" do
    render_inline(
      described_class.new(
        form: mock_form,
        query: :q,
        placeholder: "Search..."
      )
    ) do |component|
      component.with_submit_button { "Submit" }
      component.with_clear_button { "Clear" }
    end

    expect(page).to have_text("Submit")
    expect(page).to have_text("Clear")
  end
end
