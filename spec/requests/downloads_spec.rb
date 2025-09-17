# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadsController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  context "#free_download" do
    describe "downloads when files are attached" do
      let(:track) { create(:track_with_files) }
      let(:user) { create(:user) }

      before do
        sign_in user, scope: :user
      end

      it "#free_download returns the file as attachment for track" do
        get download_track_free_url(track)

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers['Content-Disposition']).to include("filename=\"tagged_mp3.mp3\"")
        expect(response.content_type).to eq("audio/mpeg")
      end

      it "#free_download should let unauthed users download" do
        get download_track_free_url(track)

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers['Content-Disposition']).to include("filename=\"tagged_mp3.mp3\"")
        expect(response.content_type).to eq("audio/mpeg")
      end
    end

    describe "downloads when files are not attached" do
      let(:track) { create(:track) }

      it "downloading a free tagged mp3 returns 404" do
        get download_track_free_path(track)

        expect(response).to redirect_to(root_url)
      end
    end
  end

  context "#product_item" do
    let(:product) { create(:track_with_files) }
    let(:license) { create(:license) }
    let(:user) { create(:guest) }
    let(:order) { create(:order, user:) }
    let(:order_item) { create(:order_item, order:) }

    before do
      sign_in user, scope: :user

      order_item.files.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
        filename: "tagged_mp3.mp3",
        content_type: "audio/mpeg"
      )
      order.update!(status: Order.statuses[:completed])
    end

    it "should return the file if user purchased the item" do
      get download_product_item_url(id: order.id, item_id: order_item.id, file_id: order_item.files.first.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers['Content-Disposition']).to include("filename=\"tagged_mp3.mp3\"")
      expect(response.content_type).to eq("audio/mpeg")
    end

    it "should not return the file if user did not purchase the item" do
      other_user = create(:admin)
      sign_in other_user, scope: :user

      get download_product_item_url(id: order.id, item_id: order_item.id, file_id: order_item.files.first.id)

      expect(response).to have_http_status(:not_found)
    end

    it "should not return the file if order is at pending status" do
      order.update!(status: Order.statuses[:pending])
      order.reload

      get download_product_item_url(id: order.id, item_id: order_item.id, file_id: order_item.files.first.id)

      expect(response).to redirect_to(root_url)
    end

    it "should not return the file if order is at failed status" do
      order.update!(status: Order.statuses[:failed])
      order.reload

      get download_product_item_url(id: order.id, item_id: order_item.id, file_id: order_item.files.first.id)

      expect(response).to redirect_to(root_url)
    end
  end
end
