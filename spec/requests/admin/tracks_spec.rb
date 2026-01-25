# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TracksController, type: :request, admin: true do
  include ActionDispatch::TestProcess::FixtureFile

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
    license = create(:license)
    controller = Admin::TracksController.new
    controller.params = ActionController::Parameters.new(
      track: {
        title: "Test",
        bpm: 140,
        key: "A MINOR",
        is_public: true,
        tagged_mp3: fixture_file_upload("tracks/tagged_mp3.mp3", "audio/mpeg"),
        untagged_mp3: fixture_file_upload("tracks/untagged_mp3.mp3", "audio/mpeg"),
        untagged_wav: fixture_file_upload("tracks/untagged_wav.wav", "audio/x-wav"),
        track_stems: fixture_file_upload("tracks/track_stems.zip", "application/zip"),
        project: fixture_file_upload("tracks/project.zip", "application/zip"),
        cover_photo: fixture_file_upload("tracks/cover_photo.png", "image/png"),
        tags_attributes: { "0" => { id: 1, name: "test", _destroy: "false" } },
        collaborators_attributes: {
          "0" => { id: 1, name: "X", role: "producer", profit_share: "0.0", publishing_share: "0.0", _destroy: true }
        },
        license_ids: [ license.id ],
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
      "tags_attributes",
      "collaborators_attributes",
      "license_ids"
    )
    expect(permitted[:tags_attributes]["0"].keys).to contain_exactly("id", "name", "_destroy")
    expect(permitted[:collaborators_attributes]["0"].keys).to contain_exactly(
      "id", "name", "role", "profit_share", "publishing_share", "_destroy"
    )
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
        expect(response).to render_template(partial: "admin/tracks/_list")
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
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          title: "New Title"
        }
      }

      it "updates the requested track" do
        track = Track.create(:track_with_files)
        put admin_track_url(track), params: { track: new_attributes }
        track.reload
        expect(track.title).to eq("New Title")
      end

      it "redirects to the track" do
        track = Track.create! valid_attributes
        put admin_track_url(track), params: { track: new_attributes }
        track.reload
        expect(response).to redirect_to(admin_tracks_url)
      end

      it "does not purge any files if all remove params are 0" do
        purge_params = {
          remove_tagged_mp3: "0",
          remove_untagged_mp3: "0",
          remove_untagged_wav: "0",
          remove_track_stems: "0",
          remove_project: "0"
        }
        track = create(:track_with_files)
        license = create(:non_exclusive_license)
        track.licenses << license

        put admin_track_url(track), params: { track: purge_params }
        expect(response).to redirect_to(admin_tracks_url)
      end

      it "fails the update if deleted deliverables are makes track unmatch license" do
        purge_params = { remove_tagged_mp3: "1" }
        track = create(:track_with_files)
        license = create(:license)
        track.licenses << license

        put admin_track_url(track), params: { track: purge_params }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "updates if deleted files still match with license" do
        purge_params = { remove_untagged_mp3: "1" }
        track = create(:track_with_files)
        license = create(:license)
        track.licenses << license

        put admin_track_url(track), params: { track: purge_params }
        expect(response).to redirect_to(admin_tracks_url)
      end

      it "updates if there are deleted files but there are no selected licenses after" do
        track_params = { remove_tagged_mp3: "1", license_ids: [] }
        track = create(:track_with_files)
        license = create(:license)
        track.licenses << license

        put admin_track_url(track), params: { track: track_params }
        expect(response).to redirect_to(admin_tracks_url)
      end
    end
  end

  describe "DELETE /destroy" do
    it "discards the requested track" do
      track = create(:track)
      id = track.id

      expect { delete admin_track_url(track) }.not_to change(Track, :count)

      track.reload

      expect(response).to have_http_status(:see_other)
      expect(track.discarded?).to be(true)
      expect(track.discarded_at).not_to be_nil
      expect(Track.kept).not_to include(track)
      expect(Track.find(id)).to eq(track)
    end

    it "redirects to the tracks list" do
      track = Track.create! valid_attributes
      delete admin_track_path(track.id)
      expect(response).to redirect_to(admin_tracks_url)
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

  describe "collaborators" do
    let!(:track) { create(:track) }
    let(:params) {
      {
        name: "Test",
        role: Collaboration::Collaborator.roles[:producer],
        profit_share: "0.0",
        publishing_share: "0.0",
        notes: "ABCDE"
      }
    }

    it "adds a new collaborator on #create" do
      post admin_tracks_url, params: {
        track: {
          title: "Test",
          genre: Track::GENRES[0],
          bpm: 111,
          collaborators_attributes: {
            "0" => params
          }
        }
      }

      collaborators = Track.last.collaborators

      expect(response).to have_http_status(302)
      expect(collaborators.size).to eq(1)
      expect(collaborators.first.name).to eq("Test")
      expect(collaborators.first.profit_share).to eq(0.0)
      expect(collaborators.first.publishing_share).to eq(0.0)
      expect(collaborators.first.notes).to eq("ABCDE")
    end

    it "adds a new collaborator on #update" do
      patch admin_track_url(track), params: {
        track: {
          collaborators_attributes: {
            "0" => params,
            "1" => params.merge(name: "Test2", profit_share: "11.1")
          }
        }
      }

      expect(response).to have_http_status(302)

      collaborators = track.reload.collaborators
      names = collaborators.pluck(:name)
      profit_shares = collaborators.pluck(:profit_share)
      publishing_shares = collaborators.pluck(:publishing_share)

      expect(names).to include("Test")
      expect(names).to include("Test2")
      expect(profit_shares).to include(11.1)
      expect(profit_shares).to include(0.0)
      expect(publishing_shares).to include(0.0)
      expect(publishing_shares).to include(0.0)
    end

    it "accepts blank collaborator notes" do
      patch admin_track_url(track), params: {
        track: {
          collaborators_attributes: {
            "0" => params.merge(notes: "")
          }
        }
      }

      track.reload

      expect(response).to have_http_status(302)
      expect(Track.last.collaborators.size).to eq(1)
      expect(Track.last.collaborators.first.notes).to be_empty
    end

    it "rejects an invalid collaborator role" do
      expect(track.collaborators.size).to eq(0)

      patch admin_track_url(track), params: {
        track: {
          collaborators_attributes: {
            "0" => params.merge(role: "invalid")
          }
        }
      }

      track.reload

      expect(response).to have_http_status(422)
      expect(track.collaborators.size).to eq(0)
    end

    it "rejects a blank name" do
      expect(track.collaborators.size).to eq(0)

      patch admin_track_url(track), params: {
        track: {
          collaborators_attributes: {
            "0" => params.merge(name: "")
          }
        }
      }

      track.reload

      expect(response).to have_http_status(422)
      expect(track.collaborators.size).to eq(0)
    end

    it "deletes an existing collaborator" do
      collaborator = create(:collaborator, entity: track)

      expect(track.reload.collaborators.size).to eq(1)

      patch admin_track_path(track), params: {
        track: {
          collaborators_attributes: {
            "0" => {
              id: collaborator.id,
              _destroy: "true"
            }
          }
        }
      }

      expect(track.reload.collaborators.size).to eq(0)
    end
  end

  describe "samples" do
    let!(:track) { create(:track) }
    let(:params) {
      {
        name: "Song",
        artist: "Test",
        link: "www.example.com"
      }
    }

    it "adds a new sample on #create" do
      post admin_tracks_url, params: {
        track: {
          title: "Test",
          genre: Track::GENRES[0],
          bpm: 111,
          samples_attributes: {
            "0" => params
          }
        }
      }

      samples = Track.last.samples

      expect(response).to have_http_status(302)
      expect(samples.size).to eq(1)
      expect(samples.first.name).to eq("Song")
      expect(samples.first.artist).to eq("Test")
      expect(samples.first.link).to eq("www.example.com")
    end

    it "adds a new sample on #update" do
      patch admin_track_url(track), params: {
        track: {
          samples_attributes: {
            "0" => params,
            "1" => { name: "Song2", artist: "Test2", link: "www.example2.com" }
          }
        }
      }

      expect(response).to have_http_status(302)

      samples = track.reload.samples
      names = samples.pluck(:name)
      artists = samples.pluck(:artist)
      links = samples.pluck(:link)

      expect(names).to include("Song")
      expect(names).to include("Song2")
      expect(artists).to include("Test")
      expect(artists).to include("Test2")
      expect(links).to include("www.example.com")
      expect(links).to include("www.example2.com")
    end

    it "accepts blank sample artist and link" do
      patch admin_track_url(track), params: {
        track: {
          samples_attributes: {
            "0" => { name: "S" }
          }
        }
      }

      track.reload

      expect(response).to have_http_status(302)
      expect(Track.last.samples.size).to eq(1)
      expect(Track.last.samples.first.name).to eq("S")
      expect(Track.last.samples.first.artist).to eq("")
      expect(Track.last.samples.first.link).to eq("")
    end

    it "rejects a blank name" do
      expect(track.samples.size).to eq(0)

      patch admin_track_url(track), params: {
        track: {
          samples_attributes: {
            "0" => params.merge(name: "")
          }
        }
      }

      track.reload

      expect(response).to have_http_status(422)
      expect(track.samples.size).to eq(0)
    end

    it "deletes an existing collaborator" do
      sample = create(:sample, track:)

      expect(track.reload.samples.size).to eq(1)

      patch admin_track_path(track), params: {
        track: {
          samples_attributes: {
            "0" => {
              id: sample.id,
              _destroy: "true"
            }
          }
        }
      }

      expect(track.reload.samples.size).to eq(0)
    end
  end

  describe "licenses" do
    let(:track) { create(:track) }
    let(:contract_details) { { delivers_mp3: false, delivers_wav: false, delivers_stems: false } }
    let(:license1) { create(:license, contract_type: License.contract_types[:free], contract_details:) }
    let(:license2) { create(:non_exclusive_license, contract_details:) }

    it "creates track with given licenses" do
      expect {
        post admin_tracks_url, params: {
          track: valid_attributes.merge(
            license_ids: [ license1.id ],
            tagged_mp3: fixture_file_upload("tracks/tagged_mp3.mp3", "audio/mpeg")
          )
        }
      }.to change(Track, :count).by(1)

      created_track = Track.last

      expect(response).to have_http_status(302)
      expect(created_track.licenses.count).to eq(1)
      expect(created_track.licenses).to include(license1)
    end

    it "updates track with given licenses" do
      track.licenses << license1

      put admin_track_url(track), params: {
        track: {
          license_ids: [ license1.id, license2.id ],
          tagged_mp3: fixture_file_upload("tracks/tagged_mp3.mp3", "audio/mpeg")
        }
      }

      expect(response).to have_http_status(302)
      expect(track.licenses.count).to eq(2)
    end

    it "does not create the track if files delivered doesn't match license contracts" do
      license = create(:non_exclusive_license, contract_details: { delivers_mp3: true, delivers_wav: false, delivers_stems: true })

      expect {
        post admin_tracks_url, params: { track: valid_attributes.merge(license_ids: [ license.id ]) }
      }.not_to change(Track, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "creates the track if files delivered match license contracts" do
      license = create(:non_exclusive_license, contract_details: { delivers_mp3: false, delivers_wav: false, delivers_stems: false })

      expect {
        post admin_tracks_url, params: { track: valid_attributes.merge(license_ids: [ license.id ]) }
      }.to change(Track, :count).by(1)

      expect(response).to have_http_status(:found)
    end

    it "does not update the track if files delivered doesn't match license contracts" do
      license = create(:non_exclusive_license, contract_details: { delivers_mp3: false, delivers_wav: false, delivers_stems: false })
      track.licenses << license
      license.update!(contract_details: { delivers_mp3: true })

      put admin_track_url(track), params: { track: { description: "ABC" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "updates the track if files delivered match license contracts" do
      license = create(:non_exclusive_license, contract_details: { delivers_mp3: false, delivers_wav: false, delivers_stems: false })
      track.licenses << license

      put admin_track_url(track), params: { track: { description: "ABC" } }

      expect(response).to have_http_status(:found)
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
