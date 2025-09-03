# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::LicensesController, type: :request, admin: true do
  let(:free_contract) {
    {
      terms_of_years: 1,
      delivers_mp3: false,
      delivers_wav: false,
      delivers_stems: false,
      document_template: "Free Template"
    }
  }
  let(:non_exclusive_contract) {
    {
      terms_of_years: 1,
      delivers_mp3: true,
      delivers_wav: false,
      delivers_stems: true,
      distribution_copies: 10000,
      streams_allowed: 10000,
      non_monetized_videos: 2,
      monetized_videos: 1,
      non_monetized_video_streams: 10000,
      monetized_video_streams: 1000,
      non_profitable_performances: 1,
      has_broadcasting_rights: true,
      radio_stations_allowed: 1,
      allow_profitable_performances: true,
      document_template: "Non Exclusive Template"
    }
  }
  let(:non_exclusive_unlimited_contract) {
    {
      terms_of_years: 1,
      delivers_mp3: true,
      delivers_wav: false,
      delivers_stems: true,
      distribution_copies: nil,
      streams_allowed: nil,
      non_monetized_videos: nil,
      monetized_videos: nil,
      non_monetized_video_streams: nil,
      monetized_video_streams: nil,
      non_profitable_performances: nil,
      has_broadcasting_rights: true,
      radio_stations_allowed: nil,
      allow_profitable_performances: true,
      document_template: "Unlimited Non Exclusive Template"
    }
  }
  let!(:params) {
    {
      title: "Test License",
      description: "Description",
      country: "CA",
      province: "ON",
      price_cents: 19.99,
      currency: "USD",
      default_for_new: true
    }
  }

  describe "GET #new" do
    it "assigns a new License and contract_type" do
      contract_type = License.contract_types[:free]
      get new_admin_license_url, params: { contract_type: }

      expect(assigns(:license)).to be_a_new(License)
      expect(assigns(:contract_type)).to eq(contract_type)
    end

    it "sets contract_type to nil if invalid" do
      get new_admin_license_url, params: { contract_type: "invalid" }

      expect(assigns(:contract_type)).to be_nil
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a free license and redirects" do
        expect {
          post admin_licenses_url, params: {
            license: params.merge(contract_type: License.contract_types[:free], contract_details: free_contract)
          }
        }.to change(License, :count).by(1)

        license = License.last
        contract = license.contract

        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")
        expect(license.country).to eq("CA")
        expect(license.province).to eq("ON")
        expect(license.price_cents).to eq(1999)
        expect(license.currency).to eq("USD")
        expect(license.default_for_new).to be(true)
        expect(contract[:terms_of_years]).to eq(1)
        expect(contract[:document_template]).to eq("Free Template")
        expect(response).to redirect_to(admin_licenses_path)
      end

      it "creates a non exclusive license and redirects" do
        expect {
          post admin_licenses_url, params: {
            license: params.merge(
              contract_type: License.contract_types[:non_exclusive],
              contract_details: non_exclusive_contract
            )
          }
        }.to change(License, :count).by(1)

        license = License.last
        contract = license.contract
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")

        expect(contract[:document_template]).to eq("Non Exclusive Template")
        expect(contract[:terms_of_years]).to eq(1)
        expect(contract[:delivers_mp3]).to be(true)
        expect(contract[:delivers_wav]).to be(false)
        expect(contract[:delivers_stems]).to be(true)
        expect(contract[:distribution_copies]).to eq(10000)
        expect(contract[:streams_allowed]).to eq(10000)
        expect(contract[:non_monetized_videos]).to eq(2)
        expect(contract[:monetized_videos]).to eq(1)
        expect(contract[:non_monetized_video_streams]).to eq(10000)
        expect(contract[:monetized_video_streams]).to eq(1000)
        expect(contract[:non_profitable_performances]).to eq(1)
        expect(contract[:has_broadcasting_rights]).to be(true)
        expect(contract[:allow_profitable_performances]).to be(true)
        expect(contract[:radio_stations_allowed]).to be(1)

        expect(response).to redirect_to(admin_licenses_path)
      end

      it "creates an unlimited non exclusive license and redirects" do
        expect {
          post admin_licenses_url, params: {
            license: params.merge(
              contract_type: License.contract_types[:non_exclusive],
              contract_details: non_exclusive_unlimited_contract
            )
          }
        }.to change(License, :count).by(1)

        license = License.last
        contract = license.contract

        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")

        expect(contract[:document_template]).to eq("Unlimited Non Exclusive Template")
        expect(contract[:terms_of_years]).to eq(1)
        expect(contract[:delivers_mp3]).to be(true)
        expect(contract[:delivers_wav]).to be(false)
        expect(contract[:delivers_stems]).to be(true)
        expect(contract[:distribution_copies]).to be_nil
        expect(contract[:streams_allowed]).to be_nil
        expect(contract[:non_monetized_videos]).to be_nil
        expect(contract[:monetized_videos]).to be_nil
        expect(contract[:non_monetized_video_streams]).to be_nil
        expect(contract[:monetized_video_streams]).to be_nil
        expect(contract[:non_profitable_performances]).to be_nil
        expect(contract[:has_broadcasting_rights]).to be(true)
        expect(contract[:allow_profitable_performances]).to be(true)
        expect(contract[:radio_stations_allowed]).to be_nil

        expect(response).to redirect_to(admin_licenses_path)
      end
    end

    context "with invalid contract" do
      it "does not save license and renders new" do
        expect {
          post admin_licenses_url, params: { license: {} }
        }.to change(License, :count).by(0)

        expect(License.count).to eq(0)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with invalid license params" do
      it "does not save and renders new" do
        license_params = params.merge(
          title: "",
          contract_type: License.contract_types[:free],
          contract_details: free_contract
        )

        expect {
          post admin_licenses_url, params: { license: license_params }
        }.to change(License, :count).by(0)

        expect(License.count).to eq(0)
        expect(response).to have_http_status(:unprocessable_content)
        expect(assigns(:license).errors[:title]).to include("is required")
      end
    end
  end

  describe "GET #edit" do
    it "sets and contract_type correctly" do
      license = create(:license)
      get edit_admin_license_url(license)

      expect(assigns(:license).id).to be(license.id)
      expect(assigns(:license).contract_details).to eq(license.contract_details)
      expect(assigns(:contract_type)).to eq(license.contract_type)
    end
  end

  describe "PUT #update" do
    let!(:license) { create(:license) }

    context "with valid params" do
      it "updates a free license and redirects" do
        put admin_license_url(license), params: {
          license: params.merge(
            contract_type: License.contract_types[:free],
            contract_details: free_contract.merge(terms_of_years: 24, document_template: "Edited"),
            title: "Modified"
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Modified")
        expect(license.contract[:terms_of_years]).to eq(24)
        expect(license.contract[:document_template]).to eq("Edited")
        expect(response).to redirect_to(admin_licenses_path)
      end

      it "updates a non exclusive license and redirects" do
        put admin_license_url(license), params: {
          license: params.merge(
            contract_type: License.contract_types[:non_exclusive],
            contract_details: non_exclusive_contract.merge(delivers_mp3: false, document_template: "Edited"),
            title: "Non Exclusive",
            price_cents: 10
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Non Exclusive")
        expect(license.price_cents).to eq(1000)
        expect(license.contract[:delivers_mp3]).to be(false)
        expect(license.contract[:document_template]).to eq("Edited")
        expect(response).to redirect_to(admin_licenses_path)
      end

      it "updates an unlimited non exclusive license and redirects" do
        put admin_license_url(license), params: {
          license: params.merge(
            contract_type: License.contract_types[:non_exclusive],
            contract_details: non_exclusive_unlimited_contract.merge(streams_allowed: nil, document_template: "Edited"),
            province: "BC"
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.province).to eq("BC")
        expect(license.contract[:streams_allowed]).to be_nil
        expect(license.contract[:document_template]).to eq("Edited")
        expect(response).to redirect_to(admin_licenses_path)
      end
    end

    context "with invalid contract" do
      it "does not save license and renders new" do
        expect(License.count).to eq(1)

        put admin_license_url(license), params: { license: {} }

        expect(License.count).to eq(1)
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with invalid license params" do
      it "does not save and renders new" do
        expect(License.count).to eq(1)

        put admin_license_url(license), params: {
          license: {
            title: "",
            contract_type: License.contract_types[:free],
            contract_details: free_contract
          }
        }

        expect(License.count).to eq(1)
        expect(response).to have_http_status(:unprocessable_content)
        expect(assigns(:license).errors[:title]).to include("is required")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:license) { create(:license) }

    it "destroys the request track" do
      expect {
        delete admin_license_url(license)
      }.to change(License, :count).by(-1)

      expect(License.count).to eq(0)
      expect(response).to have_http_status(303)
      expect(response).to redirect_to(admin_licenses_url)
      # TODO test if deletion also deletes from track
    end
  end

  describe "POST #apply_to_all" do
    let(:license) { create(:license) }

    it "should apply license to all tracks" do
      t1 = create(:track)
      t2 = create(:track)

      expect(t1.licenses.count).to eq(0)
      expect(t2.licenses.count).to eq(0)
      expect(license.tracks.count).to eq(0)

      post apply_to_all_admin_license_url(license, format: :turbo_stream)

      t1.reload
      t2.reload
      license.reload

      expect(response).to have_http_status(:ok)
      expect(t1.licenses.count).to eq(1)
      expect(t1.licenses).to include(license)
      expect(t2.licenses.count).to eq(1)
      expect(t2.licenses).to include(license)
      expect(license.tracks.count).to eq(2)
    end
  end

  describe "DELETE #remove_from_all" do
    let(:license) { create(:license) }

    it "should apply license to all tracks" do
      t1 = create(:track)
      t2 = create(:track)
      t1.licenses << license
      t2.licenses << license

      expect(t1.licenses.count).to eq(1)
      expect(t2.licenses.count).to eq(1)
      expect(license.tracks.count).to eq(2)

      delete remove_from_all_admin_license_url(license, format: :turbo_stream)

      t1.reload
      t2.reload
      license.reload

      expect(response).to have_http_status(:ok)
      expect(t1.licenses.count).to eq(0)
      expect(t2.licenses.count).to eq(0)
      expect(license.tracks.count).to eq(0)
    end
  end

  describe "admin paths", authorization_test: true do
    it "only allows admin at GET /index" do
      get admin_licenses_url
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at GET /new" do
      get new_admin_license_url
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at POST /create" do
      post admin_licenses_url, params: { licenses: params }
      expect(response).to redirect_to(root_path)
    end
  end
end
