# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::CommentComponent, type: :component do
  let(:current_user) { create(:user) }
  let(:track) { create(:track) }
  let(:comment) { create(:comment, entity: track, user: current_user) }
  let(:rendered) { render_inline(described_class.new(comment:, current_user:)) }

  it "renders the comment contents" do
    expect(rendered.text).to have_content(comment.content)
    expect(rendered.text).to have_content(comment.user.display_name)
    expect(rendered).to have_css(".avatar")
    expect(rendered).to have_css("#comment_#{comment.id}")
    expect(rendered).to have_css(".interaction-icon", count: 3)
  end
end
