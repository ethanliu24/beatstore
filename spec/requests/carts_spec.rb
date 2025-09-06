# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartsController, type: :request do
  describe "GET #show" do
    it "should be a valid page for logged in user" do
      user = create(:user)
      sign_in user, scope: :user

      get cart_path

      expect(response).to have_http_status(:ok)
    end

    it "should be a valid page for logged in user" do
      get cart_path

      expect(response).to have_http_status(:ok)
    end
  end
end
