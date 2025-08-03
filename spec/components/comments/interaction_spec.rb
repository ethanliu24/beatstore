# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::InteractionComponent, type: :component do
  let(:current_user) { create(:user) }
  let(:track) { create(:track) }
  let(:comment) { create(:comment, entity: track, user: current_user) }

  it "renders the interaction action url with a post method if user haven't iteracted" do
    rendered = render_component(comment:, current_user:, user_interacted: false)

    expect(rendered).to have_css("form[method='post']")
    expect(rendered).not_to have_css("form[method='post'] input[name='_method'][value='delete']")
  end

  it "renders the interaction action url with a post method if user had iteracted" do
    rendered = render_component(comment:, current_user:, user_interacted: true)

    expect(rendered).to have_css("form[method='post']")
    expect(rendered).to have_css("input[type='hidden'][name='_method'][value='delete']", visible: :all, count: 1)
  end

  it "should render the interaction count" do
    rendered = render_component(comment:, current_user:, interaction_count: 10000)

    expect(rendered.text).to have_content("10000")
  end

  it "renders a modal if user is not logged in" do
    rendered = render_component(comment:, current_user: nil)

    expect(rendered).to have_css("a")
  end

  private

  def render_component(
    comment:,
    interaction_count: 1,
    action: "/comments",
    current_user: nil,
    user_interacted: false,
    icon_name: "thumb-up"
  )
    render_inline(
      described_class.new(
        comment:,
        interaction_count:,
        action:,
        current_user:,
        user_interacted:,
        icon_name:
      )
    )
  end
end
