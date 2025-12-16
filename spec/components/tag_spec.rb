# frozen_string_literal: true

require "rails_helper"

RSpec.describe TagComponent, type: :component do
  it "renders tag with a hashtag infront of it" do
    track = create(:track)
    tag = create(:track_tag, track:, name: "text")
    rendered = render_inline(described_class.new(name: tag.name))

    expect(rendered).to have_css("a.tag", text: "#text")
  end
end
