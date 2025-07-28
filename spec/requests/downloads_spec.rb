# spec/requests/downloads_spec.rb
require 'rails_helper'

RSpec.describe DownloadsController, type: :request do
  context "track downloads" do
    describe "downloads when files are attached" do
      let(:track) { create(:track_with_files) }
      let(:user) { create(:user) }

      before do
        sign_in user, scope: :user
      end

      it "#free_download returns the file as attachment for track" do
        get download_track_free_url(track.id)

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers['Content-Disposition']).to include("filename=\"#{"Track with files - 111bpm c major.mp3"}\"")
        expect(response.content_type).to eq("mp3")
      end

      it "#free_download should let unauthed users download" do
        get download_track_free_url(track.id)

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        # TODO replace with track.tagged_mp3.blob.filename when frontend is updated to take the original file name uploaded
        expect(response.headers['Content-Disposition']).to include("filename=\"#{"Track with files - 111bpm c major.mp3"}\"")
        expect(response.content_type).to eq("mp3")
      end
    end
  end

  describe "downloads when files are not attached" do
    let(:track) { create(:track) }

    it "downloading a free tagged mp3 returns 404" do
      get download_track_free_path(id: 12345)

      expect(response).to have_http_status(:not_found)
    end
  end
end
