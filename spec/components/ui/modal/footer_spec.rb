# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Modal::FooterComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders with default cancel label and md size" do
    rendered = render_inline(described_class.new)

    expect(rendered).to have_css(".text-md")
    expect(rendered).to have_selector("button[data-action='click->modal-manager#close']")
  end

  it "renders with custom cancel label" do
    render_inline(described_class.new(cancel_label: "Abort"))

    expect(rendered_content).to include("Abort")
  end

  it "renders correct size class for :sm" do
    render_inline(described_class.new(cancel_label: "Cancel", size: :sm))

    expect(rendered_content).to include("text-sm")
  end

  it "renders correct size class for unknown size (:xl → fallback to text-lg)" do
    render_inline(described_class.new(size: :xl))

    expect(rendered_content).to include("text-lg")
  end

  it "renders primary action block if provided" do
    rendered = render_inline(described_class.new) do |component|
      component.with_primary_action { "Primary" }
    end

    expect(rendered.text).to have_content("Primary")
  end
end
