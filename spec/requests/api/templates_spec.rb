require 'rails_helper'

RSpec.describe Api::TemplatesController, type: :request do
  describe "GET #show" do
    it "retrieves the contract template" do
      user = create(:admin)
      sign_in user, scope: :user
      get api_templates_contracts_path(contract_type: License.contract_types[:free])
      json = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(json["template"]).to eq(Rails.configuration.templates[:contracts][:free])
    end

    it "does not allow non admin user to call" do
      user = create(:user)
      sign_in user, scope: :user
      get api_templates_contracts_path(contract_type: License.contract_types[:free])

      expect(response).to redirect_to(root_path)
    end
  end
end
