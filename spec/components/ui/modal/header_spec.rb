# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Modal::HeaderComponent, type: :component do
  it "renders with default title and size (:md)" do
    rendered = render_inline(described_class.new(title: "Header"))

    expect(rendered.text).to have_content("Header")
    expect(rendered).to have_css(".text-lg")
    expect(rendered).to have_selector("button[data-action='click->modal-manager#close']")
    expect(rendered_content).to include("Close modal")
  end

  it "renders correct size class for :xs" do
    render_inline(described_class.new(title: "XS Title", size: :xs))

    expect(rendered_content).to include("XS Title")
    expect(rendered_content).to include("text-[0.8rem]")
  end

  it "renders correct size class for :sm" do
    render_inline(described_class.new(title: "Small Title", size: :sm))

    expect(rendered_content).to include("Small Title")
    expect(rendered_content).to include("text-base")
  end

  it "renders falls back to :xl" do
    render_inline(described_class.new(title: "XL Title", size: :xl))

    expect(rendered_content).to include("XL Title")
    expect(rendered_content).to include("text-xl")
  end

  it "renders the close icon" do
    rendered = render_inline(described_class.new(title: "Close Button Test"))

    expect(rendered).to have_css(".close-modal-btn")
  end
end
