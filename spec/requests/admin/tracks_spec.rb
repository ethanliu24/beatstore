require 'rails_helper'

RSpec.describe "/admin/tracks", type: :request, admin: true do
  let(:valid_attributes) {
    {
      title: "Valid Track Title",
      key: "C MAJOR",
      bpm: 111
    }
  }

  let(:invalid_attributes) {
    {
      artist: "Beyonce"
    }
  }

  it "sanitizes parameters" do
    skip "Add attachment test later"
    controller = Admin::TracksController.new
    controller.params = ActionController::Parameters.new(
      track: {
        title: "Test",
        bpm: 140,
        key: "A MINOR",
        is_public: true,
        tagged_mp3: "",
        untagged_mp3: "",
        untagged_wav: "",
        track_stems: "",
        project: "",
        cover_photo: "",
        foo: "bar"
      }
    )
    permitted = controller.send(:sanitize_track_params)
    expect(permitted).not_to have_key("foo")
    expect(permitted.keys).to contain_exactly(
      "title",
      "key",
      "bpm",
      "is_public",
      "tagged_mp3",
      "untagged_mp3",
      "untagged_wav",
      "track_stems",
      "project",
      "cover_photo"
    )
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_admin_track_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      track = Track.create! valid_attributes
      get edit_admin_track_url(track)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Track" do
        expect {
          post admin_tracks_url, params: { track: valid_attributes }
        }.to change(Track, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Track" do
        expect {
          post admin_tracks_url, params: { track: invalid_attributes }
        }.to change(Track, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post admin_tracks_url, params: { track: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          title: "New Title"
        }
      }

      it "updates the requested track" do
        track = Track.create! valid_attributes
        patch admin_track_url(track), params: { track: new_attributes }
        track.reload
        expect(track.title).to eq("New Title")
      end

      it "redirects to the track" do
        track = Track.create! valid_attributes
        patch admin_track_url(track), params: { track: new_attributes }
        track.reload
        expect(response).to redirect_to(track_url(track))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested track" do
      track = Track.create! valid_attributes
      expect {
        delete admin_track_path(track)
      }.to change(Track, :count).by(-1)
    end

    it "redirects to the tracks list" do
      track = Track.create! valid_attributes
      delete admin_track_path(track.id)
      expect(response).to redirect_to(tracks_url)
    end
  end

  describe "admin paths", authorization_test: true do
    it "only allows admin at GET /new" do
      get new_admin_track_url
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at GET /edit" do
      track = Track.create! valid_attributes

      get edit_admin_track_path(track)
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at POST /create" do
      post admin_tracks_path, params: { track: valid_attributes }
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at PATCH or PUT /update" do
      track = Track.create! valid_attributes

      patch admin_track_url(track), params: { track: valid_attributes }
      expect(response).to redirect_to(root_path)
      put admin_track_url(track), params: { track: valid_attributes }
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at DELETE /destroy" do
      track = Track.create! valid_attributes

      delete admin_track_url(track)
      expect(response).to redirect_to(root_path)
    end
  end
end
