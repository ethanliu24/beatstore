# spec/controllers/admin/licenses_controller_spec.rb
require "rails_helper"

RSpec.describe Admin::LicensesController, type: :request, admin: true do
  let(:free_contract) {
    {
      terms_of_years: 1,
      delivers_mp3: true,
      delivers_wav: false,
      delivers_stems: true
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
      non_profitable_performances_allowed: true
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
      non_profitable_performances_allowed: true
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
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")
        expect(license.country).to eq("CA")
        expect(license.province).to eq("ON")
        expect(license.price_cents).to eq(1999)
        expect(license.currency).to eq("USD")
        expect(license.default_for_new).to be(true)
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
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")
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
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Test License")
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
        expect(response).to have_http_status(:unprocessable_entity)
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
            contract_details: free_contract,
            title: "Modified"
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Modified")
        expect(response).to redirect_to(admin_licenses_path)
      end

      it "updates a non exclusive license and redirects" do
        put admin_license_url(license), params: {
          license: params.merge(
            contract_type: License.contract_types[:non_exclusive],
            contract_details: non_exclusive_contract,
            title: "Non Exclusive",
            price_cents: 10
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.title).to eq("Non Exclusive")
        expect(license.price_cents).to eq(1000)
        expect(response).to redirect_to(admin_licenses_path)
      end

      it "updates an unlimited non exclusive license and redirects" do
        put admin_license_url(license), params: {
          license: params.merge(
            contract_type: License.contract_types[:non_exclusive],
            contract_details: non_exclusive_unlimited_contract,
            province: "BC"
          )
        }

        license = License.last
        expect(response).to have_http_status(302)
        expect(license.province).to eq("BC")
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
        expect(response).to have_http_status(:unprocessable_entity)
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
