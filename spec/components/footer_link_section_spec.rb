# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterLinkSectionComponent, type: :component do
  it "renders the section heading" do
    rendered = render_inline(
      described_class.new(
        section: "Resources",
        links: []
      )
    )

    expect(rendered).to have_text("Resources")
    expect(rendered.css("p").text).to eq("Resources")
  end

  it "renders all provided link names" do
    rendered = render_inline(
      described_class.new(
        section: "Company",
        links: [
          [ "/about", "About Us" ],
          [ "/careers", "Careers" ],
          [ "/blog", "Blog" ]
        ]
      )
    )

    expect(rendered).to have_css("a", count: 3)

    expect(rendered.css("a").map(&:text)).to eq([
      "About Us",
      "Careers",
      "Blog"
    ])
  end

  it "renders links in the order they are provided" do
    rendered = render_inline(
      described_class.new(
        section: "Ordered",
        links: [
          [ "/first", "First" ],
          [ "/second", "Second" ],
          [ "/third", "Third" ]
        ]
      )
    )

    expect(rendered.css("a").map(&:text)).to eq(
      [ "First", "Second", "Third" ]
    )
  end

  it "renders the correct number of list items" do
    rendered = render_inline(
      described_class.new(
        section: "Many Links",
        links: [
          [ "/one", "One" ],
          [ "/two", "Two" ],
          [ "/three", "Three" ],
          [ "/four", "Four" ]
        ]
      )
    )

    expect(rendered).to have_css("ul", count: 1)
    expect(rendered).to have_css("li", count: 4)
    expect(rendered).to have_css("a", count: 4)
  end

  it "renders correctly with a single link" do
    rendered = render_inline(
      described_class.new(
        section: "Legal",
        links: [
          [ "/privacy", "Privacy Policy" ]
        ]
      )
    )

    expect(rendered).to have_css("li", count: 1)
    expect(rendered.css("a").first.text).to eq("Privacy Policy")
  end

  it "renders correctly with no links" do
    rendered = render_inline(
      described_class.new(
        section: "Empty Section",
        links: []
      )
    )

    expect(rendered).to have_text("Empty Section")

    expect(rendered).to have_css("ul", count: 1)
    expect(rendered).to have_css("li", count: 0)
    expect(rendered).to have_css("a", count: 0)
  end

  it "renders external links" do
    rendered = render_inline(
      described_class.new(
        section: "External",
        links: [
          [ "https://github.com", "GitHub" ],
          [ "https://rubyonrails.org", "Rails" ]
        ]
      )
    )

    expect(rendered.css("a").map(&:text)).to eq([
      "GitHub",
      "Rails"
    ])
  end

  it "renders special characters correctly" do
    rendered = render_inline(
      described_class.new(
        section: "Special",
        links: [
          [ "/terms", "Terms & Conditions" ],
          [ "/privacy", "Privacy / Security" ]
        ]
      )
    )

    texts = rendered.css("a").map(&:text)

    expect(texts).to include("Terms & Conditions")
    expect(texts).to include("Privacy / Security")
  end

  it "renders many links correctly" do
    rendered = render_inline(
      described_class.new(
        section: "Big Footer",
        links: [
          [ "/one", "One" ],
          [ "/two", "Two" ],
          [ "/three", "Three" ],
          [ "/four", "Four" ],
          [ "/five", "Five" ],
          [ "/six", "Six" ],
          [ "/seven", "Seven" ],
          [ "/eight", "Eight" ]
        ]
      )
    )

    expect(rendered).to have_css("li", count: 8)

    expect(rendered.css("a").map(&:text)).to eq(
      [
        "One",
        "Two",
        "Three",
        "Four",
        "Five",
        "Six",
        "Seven",
        "Eight"
      ]
    )
  end

  it "renders duplicate link names if provided" do
    rendered = render_inline(
      described_class.new(
        section: "Duplicates",
        links: [
          [ "/first-help", "Help" ],
          [ "/second-help", "Help" ]
        ]
      )
    )

    expect(rendered).to have_css("a", count: 2)
    expect(rendered.css("a").map(&:text)).to eq([
      "Help",
      "Help"
    ])
  end
end
