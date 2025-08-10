# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Filter::ChipComponent, type: :component do
  let(:title) { "Genre" }
  let(:label) { "genre" }
  let(:data) { { foo: "bar" } }
  let(:close_action) { "click->track-filter#clearGenres" }

  subject(:rendered) do
    render_inline(described_class.new(
      title: title,
      label: label,
      data: data,
      close_action: close_action
    ))
  end

  it "renders the container div with given data attributes" do
    expect(rendered.css("div[data-foo='bar']")).to be_present
  end

  it "renders a span with id based on label and title text" do
    expect(rendered.css("span##{label}-chip").text).to include("#{title}:")
  end

  it "renders a close button with the correct data-action attribute" do
    expect(rendered.css("div[data-action='#{close_action}']")).to be_present
  end

  it "renders the close icon inside the close button" do
    # Assuming `icon` helper renders an SVG or something with a class including "w-3"
    expect(rendered.css("div[data-action] svg, div[data-action] .w-3")).to be_present
  end

  context "when render is false" do
    subject(:rendered) do
      render_inline(described_class.new(
        title: title,
        label: label,
        data: data,
        close_action: close_action,
        render: false
      ))
    end

    it "does not render anything" do
      expect(rendered.to_html).to be_blank
    end
  end
end
