# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::FormComponent, type: :component do
  let(:entity) { create(:track) }

  it "renders form if there is an user, i.e. logged in" do
    current_user = create(:user_with_pfp)
    rendered = render_inline(described_class.new(entity:, current_user:))

    expect(rendered).to have_css(".send-comment", count: 1)
    expect(rendered).to have_css("img.avatar")
    expect(rendered).not_to have_css("a")
  end

  it "renders form if there's no user, i.e. not logged in" do
    rendered = render_inline(described_class.new(entity:, current_user: nil))

    expect(rendered).to have_css(".send-comment", count: 1)
    expect(rendered).to have_css("svg.avatar")
    expect(rendered).to have_css("a")
  end
end
