# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RecommendationComponent, type: :component do
  let!(:recommendation) { create(:track_recommendation) }
  subject(:rendered) { render_inline(described_class.new(recommendation:)) }

  it "renders some shit" do
    expect(rendered.text).to have_content("A")
    expect(rendered).to have_css("#tags_track_recommendation_#{recommendation.id}")
  end
end
