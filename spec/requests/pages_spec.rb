# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /licensing" do
    it "returns http success" do
      get licensing_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /terms_of_service" do
    it "returns http success" do
      get terms_of_service_path

      expect(response).to have_http_status(:success)
    end

    it "renders the configured terms of service content" do
      get terms_of_service_path

      expect(response.body).to include("Terms of Service")
    end
  end

  describe "GET /privacy" do
    it "returns http success" do
      get privacy_path

      expect(response).to have_http_status(:success)
    end

    it "renders the configured privacy policy content" do
      get privacy_path

      expect(response.body).to include("Privacy Policy")
    end
  end

  describe "GET /cookies" do
    it "returns http success" do
      get cookies_path

      expect(response).to have_http_status(:success)
    end

    it "renders the configured cookies policy content" do
      get cookies_path

      expect(response.body).to include("Cookies Policy")
    end
  end
end
