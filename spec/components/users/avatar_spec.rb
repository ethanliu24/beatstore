# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::AvatarComponent, type: :component do
  it "renders a profile picture if user is has one" do
    user = create(:user_with_pfp)
    rendered = render_inline(described_class.new(user:, size: 6))

    expect(rendered).to have_css("img.avatar.w-6.h-6", count: 1)
  end

  it "renders a default avatar if user does not have a profile picture" do
    user = create(:user)
    rendered = render_inline(described_class.new(user:, size: 4))

    expect(rendered).to have_css("svg.avatar.w-3.h-3", count: 1)
  end

  it "renders a default avatar if user is annonymous" do
    rendered = render_inline(described_class.new(user: nil, size: 8))

    expect(rendered).to have_css("svg.avatar.w-7.h-7", count: 1)
  end
end
