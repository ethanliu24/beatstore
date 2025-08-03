# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::ListComponent, type: :component do
  let(:user_1) { create(:user) }
  let(:comment_1) { create(:comment, user: user_1) }
  let(:user_2) { create(:user_with_pfp) }
  let(:comment_2) { create(:comment, user: user_2) }

  it "renders the comment contents if there are comments" do
    rendered = render_inline(described_class.new(
      comments: [ comment_1, comment_2 ],
      current_user: user_1
    ))

    expect(rendered).to have_css(".comment", count: 2)
  end

  it "renders no comments if there are no comments" do
    rendered = render_inline(described_class.new(comments: [], current_user: user_1))

    expect(rendered).to have_css(".comment", count: 0)
  end
end
