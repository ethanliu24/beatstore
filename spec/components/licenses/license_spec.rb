# frozen_string_literal: true

require "rails_helper"

RSpec.describe Licenses::LicenseComponent, type: :component do
  it "renders the license contents" do
    license = create(:license, default_for_new: true)
    rendered = render_inline(described_class.new(license:))

    expect(rendered).to have_css("div.flex.justify-start.items-center.gap-2", count: 4)
    expect(rendered).to have_css("#license_#{license.id}")
  end

  it "does not render default for new indicator if license is not" do
    license = create(:license, default_for_new: false)
    rendered = render_inline(described_class.new(license:))

    expect(rendered).to have_css("div.flex.justify-start.items-center.gap-2", count: 3)
  end
end
