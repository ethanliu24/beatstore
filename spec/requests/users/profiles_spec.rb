require 'rails_helper'

RSpec.describe Users::ProfilesController, type: :request do
  let(:user) { build(:user) }

  describe "GET /edit" do
    it "should allow authenticated users enter" do
      sign_in user, scope: :user
      get edit_users_profile_url
      expect(response).to have_http_status(200)
    end

    it "should redirect unauthenticated users" do
      get edit_users_profile_url
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
