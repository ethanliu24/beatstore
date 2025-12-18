# frozen_string_literal: true

require 'rails_helper'
require "pdf/reader"
require "stringio"

RSpec.describe DownloadsController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  context "#get_free_download" do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    it "should return downloaded file if it exists" do
      track = create(:track_with_files)
      free_download = create(:free_download, user:, track:)
      get get_free_download_path(free_download)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers['Content-Disposition']).to include("filename=\"tagged_mp3.mp3\"")
      expect(response.content_type).to eq("audio/mpeg")
    end

    it "should not return downloaded file if it does not exist and return 404" do
      track = create(:track)
      free_download = create(:free_download, user:, track:)
      get get_free_download_path(free_download)

      expect(response).to have_http_status(:not_found)
    end
  end

  context "#create_free_download" do
    let(:track) { create(:track_with_files) }
    let!(:user) { create(:user) }
    let(:params) {
      {
        free_download: {
          customer_name: "ABC",
          email: user.email
        }
      }
    }

    describe "sends correct data when files are attached" do
      before do
        sign_in user, scope: :user
      end

      it "returns the get href download link for free download" do
        post create_free_download_path(track, params:)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        free_download = FreeDownload.last

        expect(json).to include("download_url")
        expect(json["download_url"]).to eq(get_free_download_path(free_download))
      end

      it "should let unauthed users create" do
        sign_out user
        post create_free_download_path(track, params:)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        free_download = FreeDownload.last

        expect(json).to include("download_url")
        expect(json["download_url"]).to eq(get_free_download_path(free_download))
      end

      it "adds a free download record" do
        expect {
          post create_free_download_path(track, params:)
        }.to change(FreeDownload, :count).by(1)

        expect(response).to have_http_status(:ok)
      end

      it "doesn't create download record when track is discarded" do
        track.discard!
        track.reload
        post create_free_download_path(track, params:)

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "doesn't create download record when files are not attached" do
      let(:track) { create(:track) }

      it "downloading a free tagged mp3 returns 404" do
        post create_free_download_path(track, params:)

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "invalid free download params" do
      it "should not create download record if customer email is missing and returns 422" do
        params = {
          free_download: { customer_name: "ABC" }
        }

        expect {
          post create_free_download_path(track, params:)
        }.not_to change(FreeDownload, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "should not create download record if customer name is missing and returns 422" do
        params = {
          free_download: { email: "email@example.com" }
        }

        expect {
          post create_free_download_path(track, params:)
        }.not_to change(FreeDownload, :count)

        expect(response).to have_http_status(:unprocessable_content)
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
      other_user = create(:user)
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

    it "should let admins download any product" do
      admin = create(:admin)
      sign_in admin, scope: :user

      get download_product_item_url(id: order.id, item_id: order_item.id, file_id: order_item.files.first.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers['Content-Disposition']).to include("filename=\"tagged_mp3.mp3\"")
      expect(response.content_type).to eq("audio/mpeg")
    end
  end

  context "#order_item_contract" do
    let!(:user) { create(:user) }
    let!(:track) { create(:track) }
    let!(:license) { create(:license) }
    let!(:order) { create(:order, user:) }
    let!(:order_item) { create(
      :order_item,
      order:,
      product_snapshot: Snapshots::TakeTrackSnapshotService.new(track:).call,
      license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license:).call
    )}
    let!(:transaction) { create(:payment_transaction, order:, customer_name: "ABC") }

    before do
      order.update!(status: Order.statuses[:completed])
      order.reload

      sign_in user, scope: :user
    end

    it "lets the purchaser download the contract pdf" do
      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.content_type).to eq("application/pdf")
    end

    it "lets the admin download the contract pdf" do
      admin = create(:admin)
      sign_in admin, scope: :user

      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.content_type).to eq("application/pdf")
    end

    it "lets admin download the contract even if order is not completed" do
      order.update!(status: Order.statuses[:pending])
      admin = create(:admin)
      sign_in admin, scope: :user

      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.content_type).to eq("application/pdf")
    end

    it "does not let the admin download the contract pdf" do
      other_user = create(:guest)
      sign_in other_user, scope: :user

      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:unauthorized)
    end

    it "does not let the contract to be downloaded if the order has failed" do
      order.update!(status: Order.statuses[:failed])

      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:unauthorized)
    end

    it "does not let the contract to be downloaded if the order is pending" do
      order.update!(status: Order.statuses[:pending])

      get download_order_item_contract_path(order_item.id)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "#contract" do
    let(:license) { create(:license) }
    let(:track) { create(:track) }

    it "renders a track contract and sends it" do
      get download_contract_path(license, entity: Track.name, entity_id: track.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers['Content-Disposition']).to include("filename=\"Free Download - #{license.title}.pdf\"")
      expect(response.content_type).to eq("application/pdf")
    end

    it "sends an empty contract if entity is not supported" do
      get download_contract_path(license, entity: "Not Supported", entity_id: track.id)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers['Content-Disposition']).to include("filename=\"Free Download - #{license.title}.pdf\"")
      expect(response.content_type).to eq("application/pdf")

      reader = PDF::Reader.new(StringIO.new(response.body))
      pdf_text = reader.pages.map(&:text).join("\n")
      expect(pdf_text).to be_blank
    end

    it "returns 404 if license not found" do
      get download_contract_path(0, entity: Track.name, entity_id: track.id)

      expect(response).to have_http_status(:not_found)
    end
  end
end
