# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageTitleComponent, type: :component do
  it "renders a title and a subtitle" do
    rendered = render_inline(described_class.new(title: "Abcd", subtitle: "1234"))

    expect(rendered.text).to include("Abcd")
    expect(rendered.text).to include("1234")
  end
end
