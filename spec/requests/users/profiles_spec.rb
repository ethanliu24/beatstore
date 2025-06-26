require 'rails_helper'

RSpec.describe Users::ProfilesController, type: :request do
  let(:user) { build(:user) }

  describe "GET #edit" do
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

  describe "PATCH #udpate" do
    let(:update_params) {
      {
        display_name: "Diddler",
        biography: "I am the diddler"
      }
    }

    before do
      @user = create(:user)
      sign_in @user, scope: :user
    end

    it "should update non credential user info" do
      old_display_name = @user.display_name
      old_bio = @user.biography

      patch users_profile_url, params: { user: update_params }
      expect(response).to have_http_status(302)

      @user.reload
      expect(@user.display_name).to eq("Diddler")
      expect(@user.display_name).not_to eq(old_display_name)
      expect(@user.biography).to eq("I am the diddler")
      expect(@user.biography).not_to eq(old_bio)
    end

    it "should not update if any data is invalid" do
      old_display_name = @user.display_name

      patch users_profile_url, params: { user: { display_name: "a" * (User::DISPLAY_NAME_LENGTH + 1) } }
      expect(response).to have_http_status(422)

      @user.reload
      expect(@user.display_name).to eq(old_display_name)
    end

    it "should upload profile picture" do
      skip "add active storage for user pfp upload test #{__FILE__}"
    end

    it "should sanitize parameters" do
      patch users_profile_url, params: { user: { **update_params, foo: :bar } }
      expect(response).to have_http_status(302)
      expect(@user.respond_to?(:display_name)).to be true
      expect(@user.respond_to?(:biography)).to be true
      expect(@user.respond_to?(:foo)).to be false
    end
  end
end
