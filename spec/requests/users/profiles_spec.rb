require 'rails_helper'

RSpec.describe Users::ProfilesController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { create(:user) }

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
      expect(@user.profile_picture).not_to be_attached

      patch users_profile_url, params: {
        user: {
          profile_picture: fixture_file_upload("users/profile_picture.png", "image/png")
        }
      }

      expect(response).to have_http_status(302)

      @user.reload
      expect(@user.profile_picture).to be_attached
    end

    it "should sanitize parameters" do
      controller = Users::ProfilesController.new
      controller.params = ActionController::Parameters.new(
        user: {
          **update_params,
          profile_picture: fixture_file_upload("users/profile_picture.png", "image/png"),
          foo: :bar
        }
      )

      permitted = controller.send(:user_params)
      expect(permitted).not_to have_key("foo")
      expect(permitted.keys).to contain_exactly(
        "display_name",
        "biography",
        "profile_picture",
      )
    end
  end
end
