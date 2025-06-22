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

  it "google creates a user from omniauth" do
    expect {
      post user_google_oauth2_omniauth_callback_url
    }.to change(User, :count).by(1)

    user = User.last
    expect(user.provider).to eq("google_oauth2")
    expect(user.uid).to eq("123456")
    expect(user.email).to eq("test@example.com")
    expect(user.display_name).to eq("Test")
    expect(user.profile_picture).to be_attached
  end
end
