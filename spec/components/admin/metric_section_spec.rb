# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MetricSectionComponent, type: :component do
  it "renders the title and charts" do
    render_inline(described_class.new(title: "Revenue")) do |component|
      component.with_charts do
        "<div>Chart Content</div>".html_safe
      end
    end

    expect(page).to have_text("Revenue")
    expect(page).to have_text("Chart Content")
  end

  it "renders the accordion expanded" do
    render_inline(described_class.new(title: "Revenue")) do |component|
      component.with_charts { "Chart Content" }
    end

    expect(page).to have_css(
      '[data-accordion-expand-initially-value="true"]'
    )
  end
end
