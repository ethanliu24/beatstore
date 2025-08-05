# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Dropdown::LinkComponent, type: :component do
  it "renders a link with text and icon" do
    rendered = render_inline(described_class.new(
      url: "/",
      text: "Dashboard",
      icon: "eye",
      icon_size: 4
    ))

    expect(rendered).to have_css("a.dropdown-link", text: "Dashboard")
    expect(rendered).to have_css("svg[class*='w-4'][class*='h-4']")
  end

  it "adds custom classes to the link" do
    rendered = render_inline(described_class.new(
      url: "/",
      text: "Settings",
      icon: "eye",
      icon_size: 5,
      classes: "text-blue-500"
    ))

    expect(rendered).to have_css("a.dropdown-link.text-blue-500", text: "Settings")
  end

  it "renders the correct icon size" do
    rendered = render_inline(described_class.new(
      url: "/",
      text: "Profile",
      icon: "eye",
      icon_size: 6
    ))

    expect(rendered).to have_css("svg[class*='w-6'][class*='h-6']")
  end
end
