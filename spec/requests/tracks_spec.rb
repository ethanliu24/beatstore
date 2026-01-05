require 'rails_helper'

RSpec.describe TracksController, type: :request do
  let(:valid_attributes) {
    {
      title: "Valid Track Title",
      key: "C MAJOR",
      bpm: 111,
      genre: Track::GENRES[0]
    }
  }

  let(:invalid_attributes) {
    {
      title: nil,
      artist: ""
    }
  }

  describe "GET /index" do
    it "renders a successful response" do
      Track.create! valid_attributes
      get tracks_url
      expect(response).to be_successful
    end

    it "renders public tracks only" do
      Track.create! valid_attributes.merge({ title: "Public Track", is_public: true })
      Track.create! valid_attributes.merge({ title: "Private Track", is_public: false })

      get tracks_url
      expect(response).to be_successful
      expect(response.body).to include("Public Track")
      expect(response.body).not_to include("Private Track")
    end

    context "renders track list if request is turbo frame request" do
      it "renders only the partial" do
        get tracks_url
        assert_response :success

        get tracks_url, headers: { "Turbo-Frame" => "track-list" }, params: { q: { title_cont: "test" } }

        assert_response :success
        expect(response.body).to include("id=\"no-tracks-message\"")
      end
    end
  end

  describe "GET /show" do
    let(:private_track) { create(:track, is_public: false) }

    it "renders a successful response" do
      track = Track.create! valid_attributes
      get track_url(id: track.slug_param)
      expect(response).to be_successful
    end

    it "caps the number of similar tracks recommended" do
      track = Track.create! valid_attributes

      (TracksController::SIMILAR_TRACKS_RECOMMENDATION_LIMIT + 1).times do |i|
        valid_attributes[:title] = "RECOMMENDED_TRACK"
        Track.create! valid_attributes
      end

      get track_url(id: track.slug_param)
      expect(Capybara.string(response.body)).to have_css(
        "[data-track-title='RECOMMENDED_TRACK']",
        count: TracksController::SIMILAR_TRACKS_RECOMMENDATION_LIMIT
      )
    end

    it "doesn't allow non admins to see private tracks" do
      user = create(:user)
      sign_in user, scope: :user

      get track_url(id: private_track.slug_param)
      expect(response).to have_http_status(:not_found)
    end

    it "allows admins to see private tracks" do
      admin = create(:admin)
      sign_in admin, scope: :user

      get track_url(id: private_track.slug_param)
      expect(response).to be_successful
    end

    it "doesn't fetch discarded tracks" do
      track = create(:track)
      get track_url(id: track.slug_param)

      expect(response).to be_successful

      track.discard!
      track.reload
      get track_url(track)

      expect(response).to have_http_status(:not_found)
    end

    it "fetches tracks with the slugified param" do
      track = create(:track)
      get track_url(id: track.slug_param)
      expect(response).to be_successful
    end

    it "redirects to the newest slugified url" do
      track = create(:track)
      slug_param = track.slug_param
      url = track_url(id: slug_param)
      track.update!(title: "New")
      track.reload

      get url

      expect(slug_param).not_to eq(track.slug_param)
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to(track_url(id: track.slug_param))
    end

    it "redirects to the slugified url if param id is the original bigint id" do
      track = create(:track)
      get track_path(track)

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to(track_url(id: track.slug_param))
    end
  end
end
