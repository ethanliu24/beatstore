require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  let!(:user) { create(:user, email: "customer@email.com") }

  let(:valid_params) {
    {
      email: "customer@email.com",
      password: "Password1!"
    }
  }

  describe "POST #create" do
    it "should sign user in with correct parameters and redirect to previous page" do
      get tracks_path
      expect(response).to have_http_status(:success)

      post new_user_session_path, params: { user: valid_params }
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(tracks_path)
    end

    it "should reject sign in with a non registered email" do
      params = {
        email: "not.registered@email.com",
        password: "Password1!"
      }

      post new_user_session_path, params: { user: params }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t("authentication.email_does_not_exist"))
    end

    it "should reject sign in with an incorrect password" do
      params = {
        email: "customer@email.com",
        password: "incorrect"
      }

      post new_user_session_path, params: { user: params }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t("authentication.incorrect_password"))
    end

    it "should allow sign in after first submission is unsuccessful" do
      post new_user_session_path, params: { user: { email: "customer@email.com", password: "incorrect" } }
      expect(response).to have_http_status(:unprocessable_entity)
      post new_user_session_path, params: { user: valid_params }
      expect(response).to have_http_status(:see_other)
    end
  end
end
