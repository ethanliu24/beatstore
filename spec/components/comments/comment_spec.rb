# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::CommentComponent, type: :component do
  let(:comment) { create(:comment) }
  let(:rendered) { render_inline(described_class.new(comment:)) }

  it "renders the comment contents" do
    expect(rendered.text).to include(comment.content)
    expect(rendered.text).to include(comment.user.display_name)
    expect(rendered).to have_css(".avatar")
    # TODO test that there are 3 interactions
  end
end
