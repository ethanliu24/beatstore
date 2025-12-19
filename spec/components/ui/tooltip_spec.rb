# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::TooltipComponent, type: :component do
  it "renders the tooltip body" do
    rendered = render_inline(
      described_class.new(anchor_id: "test-anchor", position: "top")
    ) do |tooltip|
      tooltip.with_body do
        "<div class='content'>Tooltip Content</div>".html_safe
      end
    end

    expect(rendered).to have_selector("div.content", text: "Tooltip Content")
  end

  it "renders the tooltip container with correct data attributes" do
    render_inline(
      described_class.new(anchor_id: "anchor-123", position: "bottom")
    ) { "Body" }

    expect(page).to have_css(
      "[data-controller='tooltip-manager']"
    )
    expect(page).to have_css(
      "[data-tooltip-manager-anchor-id-value='anchor-123']"
    )
    expect(page).to have_css(
      "[data-tooltip-manager-position-value='bottom']"
    )
  end

  it "renders both arrow elements" do
    render_inline(
      described_class.new(anchor_id: "anchor", position: "top")
    ) { "Arrow test" }

    expect(page).to have_css(
      "[data-tooltip-manager-target='arrowX']"
    )
    expect(page).to have_css(
      "[data-tooltip-manager-target='arrowY']"
    )
  end

  it "has base tooltip styling classes" do
    render_inline(
      described_class.new(anchor_id: "anchor", position: "top")
    ) { "Styled tooltip" }

    expect(page).to have_css(".bg-tooltip-bg")
    expect(page).to have_css(".text-tooltip-text")
    expect(page).to have_css(".rounded")
  end
end
