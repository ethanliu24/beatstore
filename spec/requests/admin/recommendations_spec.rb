# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::LicensesController, type: :request, admin: true do
  let(:track) { create(:track) }
  let!(:tag1) { create(:track_tag, name: "1", track:) }
  let!(:tag2) { create(:track_tag, name: "2", track:) }
  let!(:tag3) { create(:track_tag, name: "3", track:) }

  describe "#new" do
    it "assigns a new track recommendations with all tags as not selected" do
      get new_admin_recommendation_url

      expected_tags = [
        { name: "1", selected: false },
        { name: "2", selected: false },
        { name: "3", selected: false }
      ]

      expect(assigns(:recommendation)).to be_a_new(TrackRecommendation)
      expect(assigns(:tags)).to eq(expected_tags)
    end
  end

  describe "admin paths", authorization_test: true do
    it "only allows admin at GET /index" do
      get admin_recommendations_url
      expect(response).to redirect_to(root_path)
    end
  end
end
