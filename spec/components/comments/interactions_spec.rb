# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::InteractionsComponent, type: :component do
  let(:current_user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:track) { create(:track) }
  let(:comment) { create(:comment, entity: track, user: current_user) }
  let!(:comment_like_1) { create(:comment_like, comment:, user: current_user) }
  let!(:comment_like_2) { create(:comment_like, comment:, user: admin) }
  let!(:comment_dislike) { create(:comment_dislike, comment:, user: create(:user_with_pfp)) }

  it "renders three interactions including the delete button if user is the comment auth" do
    rendered = render_inline(described_class.new(comment:, current_user:))

    expect(rendered).to have_css(".comment-interaction", count: 3)
    expect(rendered).to have_css(".comment-delete-btn", count: 1)
    expect(rendered.text).to have_content("2")
    expect(rendered.text).to have_content("1")
  end

  it "should not render delete button if user is not the comment author" do
    rendered = render_inline(described_class.new(comment:, current_user: nil))

    expect(rendered).not_to have_css(".comment-delete-btn")
  end

  it "should render delete button if user is admin" do
    rendered = render_inline(described_class.new(comment:, current_user: admin))

    expect(rendered).to have_css(".comment-delete-btn", count: 1)
  end
end
