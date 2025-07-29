require 'rails_helper'

RSpec.describe "Api::Tracks", type: :request do
  describe "GET /show" do
    let(:track) { create(:track_with_files) }

    it "should return track data if track is public and has previews" do
      get api_track_url(track)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(json["id"]).to eq(track.id)
      expect(json["title"]).to eq(track.title)
      expect(json["bpm"]).to eq(track.bpm)
      expect(json["key"]).to eq(track.key)
      expect(json["liked_by_user"]).to be(false)
      expect(json["cover_photo_url"]).to eq("")
      expect(json["preview_url"]).not_to eq("")
    end

    it "should return track data if track is private but user is admin" do
      admin = create(:admin)
      sign_in admin, scope: :user
      get api_track_url(track)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(json["id"]).to eq(track.id)
      expect(json["title"]).to eq(track.title)
      expect(json["bpm"]).to eq(track.bpm)
      expect(json["key"]).to eq(track.key)
      expect(json["liked_by_user"]).to be(false)
      expect(json["cover_photo_url"]).to eq("")
      expect(json["preview_url"]).not_to eq("")
    end

    it "should return 404 if track id is invalid" do
      get api_track_url(id: track.id + 1)

      expect(response).to have_http_status(:not_found)
    end

    it "should return 404 if track has no previews" do
      track_no_preview = create(:track)
      get api_track_url(track_no_preview)

      expect(response).to have_http_status(:not_found)
    end

    it "should return 404 if track is private but current user is not admin" do
      user = create(:user)
      sign_in user, scope: :user
      track.update!(is_public: false)

      get api_track_url(track)

      expect(response).to have_http_status(:not_found)
    end
  end
end
