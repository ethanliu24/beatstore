require 'rails_helper'

RSpec.describe Admin::TracksController, type: :request, admin: true do
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
        tag_attributes: { "0" => { id: 1, name: "test", _destroy: "false" } },
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
      "cover_photo",
      "tag_attributes"
    )
    expect(permitted[:tags_attributes]["0"].keys).to contain_exactly("id", "name", "_destroy")
  end

  describe "GET /index" do
    it "renders all tracks" do
      Track.create! valid_attributes.merge({ title: "Public Track", is_public: true })
      Track.create! valid_attributes.merge({ title: "Private Track", is_public: false })

      get admin_tracks_url
      expect(response).to be_successful
      expect(response.body).to include("Public Track", "Private Track")
    end

    context "renders track list if request is turbo frame request" do
      it "renders only the partial" do
        get admin_tracks_url
        assert_response :success

        get admin_tracks_url, headers: { "Turbo-Frame" => "track-list" }, params: { q: { title_cont: "test" } }

        assert_response :success
        expect(response).to render_template(partial: "admin/tracks/_track_list")
      end
    end
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
        expect(response).to redirect_to(admin_tracks_url)
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
      expect(response).to redirect_to(admin_tracks_url)
    end

    it "destroys all tags when the track is destroyed" do
      track = create(:track)
      tag1 = create(:track_tag, track: track, name: "t1")
      tag2 = create(:track_tag, track: track, name: "t2")

      expect(track.reload.tags.where(name: "t1").count).to eq(1)
      expect(track.reload.tags.where(name: "t2").count).to eq(1)
      expect { track.destroy }.to change { Track::Tag.count }.by(-2)
      expect(Track::Tag.where(id: [ tag1.id, tag2.id ])).to be_empty
    end
  end

  describe "tags" do
    let!(:track) { create(:track, title: "Duplicate", genre: Track::GENRES[0], bpm: 111) }

    it "adds a new tag on #create" do
      post admin_tracks_url(track), params: {
        track: {
          title: "Test",
          genre: Track::GENRES[0],
          bpm: 111,
          tags_attributes: {
            "0" => { name: "test" }
          }
        }
      }
      expect(Track.last.tags.pluck(:name)).to include("test")
    end

    it "adds a new tag on #update" do
      patch admin_track_url(track), params: {
        track: {
          tags_attributes: {
            "0" => { name: "test" },
            "1" => { name: "test_again" }
          }
        }
      }

      tags = track.reload.tags.pluck(:name)
      expect(tags).to include("test")
      expect(tags).to include("test_again")
    end

    it "rejects a duplicate tag name" do
      create(:track_tag, track: track, name: "duplicate")

      patch admin_track_url(track), params: {
        track: {
          tags_attributes: {
            "0" => { name: "duplicate" }
          }
        }
      }

      expect(track.reload.tags.where(name: "duplicate").count).to eq(1)
    end

    it "rejects a blank tag name" do
      patch admin_track_url(track), params: {
        track: {
          tags_attributes: {
            "0" => { name: "" }
          }
        }
      }

      expect(track.reload.tags.pluck(:name)).not_to include("")
    end

    it "deletes an existing tag" do
      tag = create(:track_tag, track: track, name: "trap")

      patch admin_track_path(track), params: {
        track: {
          tags_attributes: {
            "0" => {
              id: tag.id,
              _destroy: "true"
            }
          }
        }
      }

      expect(track.reload.tags.find_by(id: tag.id)).to be_nil
    end

    it "does not delete a tag not associated with the track" do
      create(:track_tag, track: track, name: "tag")
      other_track = create(:track)
      other_tag = create(:track_tag, track: other_track, name: "other")

      patch admin_track_path(track), params: {
        track: {
          tags_attributes: {
            "0" => {
              id: other_tag.id,
              _destroy: "1"
            }
          }
        }
      }

      expect(Track::Tag.find_by(id: other_tag.id)).not_to be_nil
    end
  end

  describe "admin paths", authorization_test: true do
    it "only allows admin at GET /index" do
      get admin_tracks_url
      expect(response).to redirect_to(root_path)
    end

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
