require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/contact/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/contact/create"
      expect(response).to have_http_status(:success)
    end
  end
end
