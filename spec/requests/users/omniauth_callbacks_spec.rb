require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456",
      info: {
        email: "test@example.com",
        name: "Test",
        image: "https://example.com/avatar.jpg"
      },
      credentials: {
        token: "token",
        expires_at: Time.now + 1.week
      }
    })

    allow(Faraday).to receive(:get).and_return(
      instance_double(Faraday::Response,
        success?: true,
        body: "fake-image-data",
        headers: { "content-type" => "image/jpeg" }
      )
    )
  end

  describe "google_oauth2 omniauth" do
    it "directs user to google login page" do
      post user_google_oauth2_omniauth_authorize_url
      expect(response).to have_http_status(302)
    end

    it "creates a user" do
      expect {
        post user_google_oauth2_omniauth_callback_url
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.email).to eq("test@example.com")
      expect(user.display_name).to eq("Test")
      expect(user.username).to eq("test")
      expect(user.encrypted_password).not_to be(nil)
    end

    it "redirects user if login failed" do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      post user_google_oauth2_omniauth_callback_url

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
