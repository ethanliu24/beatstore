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

  describe "#create" do
    let(:params) {
      {
        track_recommendation: {
          group: "Test",
          tag_names: [ tag1.name, tag2.name, tag3.name ].to_json,
          display_image: fixture_file_upload("recommendations/display_image.png", "image/png")
        }
      }
    }

    it "creates a track recommendation" do
      expect {
        post admin_recommendations_url, params: params
      }.to change(TrackRecommendation, :count).by(1)

      rec = TrackRecommendation.last

      expect(response).to redirect_to(admin_recommendations_path)
      expect(rec.group).to eq("Test")
      expect(rec.tag_names.length).to eq(3)
      expect(rec.tag_names).to include(tag1.name)
      expect(rec.tag_names).to include(tag2.name)
      expect(rec.tag_names).to include(tag3.name)
      expect(rec.display_image.attached?).to eq(true)
      expect(rec.disabled).to eq(false)
    end

    it "should have the smallest rank when inserted" do
      expect {
        params[:track_recommendation][:group] = "G1"
        post admin_recommendations_url, params: params

        params[:track_recommendation][:group] = "G2"
        post admin_recommendations_url, params: params
      }.to change(TrackRecommendation, :count).by(2)

      r1 = TrackRecommendation.first
      r2 = TrackRecommendation.last

      expect(r2.display_order_rank < r1.display_order_rank).to be(true)
    end

    it "does not create a recommendation if group is not provided" do
      expect {
        params[:track_recommendation][:group] = nil
        post admin_recommendations_url, params: params
      }.to change(TrackRecommendation, :count).by(0)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not create a recommendation if tag name is empty" do
      expect {
        params[:track_recommendation][:tag_names] = []
        post admin_recommendations_url, params: params
      }.to change(TrackRecommendation, :count).by(0)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "#edit" do
    let(:recommendation) { create(:track_recommendation, tag_names: [ tag1.name ]) }

    it "assigns the track recommendations with all tags sorted" do
      get edit_admin_recommendation_url(recommendation)

      expected_tags = [
        { name: "1", selected: true },
        { name: "2", selected: false },
        { name: "3", selected: false }
      ]

      expect(assigns(:recommendation)).to eq(recommendation)
      expect(assigns(:tags)).to eq(expected_tags)
    end
  end

  describe "#update" do
    let(:recommendation) { create(:track_recommendation) }

    it "updates the recommendation correctly" do
      put admin_recommendation_url(recommendation), params: {
        track_recommendation: {
          group: "Updated",
          tag_names: [ tag1.name ].to_json
        }
      }

      recommendation = TrackRecommendation.last

      expect(response).to redirect_to(admin_recommendations_url)
      expect(recommendation.group).to eq("Updated")
      expect(recommendation.tag_names).to eq([ tag1.name ])
    end

    it "does not update the recommendation if group is missing" do
      put admin_recommendation_url(recommendation), params: {
        track_recommendation: { group: nil }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not update the recommendation if tag names is empty" do
      put admin_recommendation_url(recommendation), params: {
        track_recommendation: { tag_names: [].to_json }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "destroy" do
    let!(:recommendation) { create(:track_recommendation) }

    it "should delete the recommendation" do
      expect {
        delete admin_recommendation_url(recommendation)
      }.to change(TrackRecommendation, :count).by(-1)

      expect(response).to have_http_status(:see_other)
    end
  end

  describe "admin paths", authorization_test: true do
    it "only allows admin at GET /index" do
      get admin_recommendations_url
      expect(response).to redirect_to(root_path)
    end
  end
end
