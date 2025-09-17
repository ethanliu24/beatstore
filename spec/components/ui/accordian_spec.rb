# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::AccordianComponent, type: :component do
  it "renders the summary and body slots" do
    render_inline(described_class.new) do |c|
      c.with_summary { "Summary" }
      c.with_body { "Body" }
    end

    expect(page).to have_content("Summary")
    expect(page).to have_content("Body")
    expect(page).to have_css("button[data-accordian-target='summary']")
    expect(page).to have_css("div[data-accordian-target='body']")
    expect(page).to have_css("svg[data-accordian-target='expandIcon']")
  end

  it "applies classes to button" do
    render_inline(described_class.new) do |c|
      c.with_summary { "Title" }
      c.with_body { "Details" }
    end

    expect(page).to have_css("button.flex.justify-between.items-center.w-full.hover\\:bg-hover.rounded")
  end

  it "applies classes to body container" do
    render_inline(described_class.new) do |c|
      c.with_summary { "Title" }
      c.with_body { "Details" }
    end

    expect(page).to have_css(
      "div.pl-8.my-2.max-h-0.overflow-hidden.transform-\\[max-height\\].duration-200.ease-out",
      text: "Details"
    )
  end
end
