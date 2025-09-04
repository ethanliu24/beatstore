require 'rails_helper'

RSpec.describe Users::HeartsController, type: :request do
  describe "GET /index" do
    context "user is signed in" do
      before do
        @user = create(:user)
        sign_in @user, scope: :user
      end

      it "gets the user's liked tracks page" do
        get users_hearts_url
        expect(response).to have_http_status(200)
      end
    end

    context "user is not signed in" do
      it "should redirect user to sign in" do
        get users_hearts_url
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
