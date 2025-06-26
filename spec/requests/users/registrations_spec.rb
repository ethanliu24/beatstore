require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do
  describe "POST #create" do
    before do
      Mail::TestMailer.deliveries.clear
    end

    it "creates a new user when parameters are valid" do
      params = {
        user: {
          email: "valid.signup.param@example.com",
          display_name: "diddler",
          password: "Password1!",
          password_confirmation: "Password1!"
        }
      }

      expect {
        post user_registration_url, params: params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:redirect)
      expect(User.last.email).to eq("valid.signup.param@example.com")
    end

    it "does not create a new user when parameters are invalid" do
      invalid_params = {
        user: {
          email: "invalid_email",
          password: "a",
          password_confirmation: "a"
        }
      }

      expect {
        post user_registration_url, params: invalid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(assigns(:user).errors).not_to be_empty
    end

    it "should allow fields <email>, <display_name>, <password>, and <password_confirmation> only" do
      params = {
        user: {
          email: "signup.sanitization@example.com",
          display_name: "signup.sanitization",
          password: "Password1!",
          password_confirmation: "Password1!",
          extra_field: "should_not_be_allowed"
        }
      }

      post user_registration_url, params: params

      created_user = User.last
      expect(created_user.email).to eq("signup.sanitization@example.com")
      expect(created_user.display_name).to eq("signup.sanitization")
      expect { created_user.extra_field }.to raise_error(NoMethodError)
    end

    context "username generation" do
      let(:params) {
        {
          email: "generated.username@example.com",
          display_name: "diddler",
          password: "Password1!",
          password_confirmation: "Password1!"
        }
      }

      it "should generate a username" do
        post user_registration_url, params: { user: params }
        created_user = User.last
        expect(created_user.username).to eq("generated_username")
      end

      it "should increment username suffix if it exists" do
        expect {
          post user_registration_url, params: { user: params }
        }.to change(User, :count).by(1)

        expect {
          params[:email] = "generated,username@example.com"
          post user_registration_url, params: { user: params }
        }.to change(User, :count).by(1)

        created_user = User.last
        expect(created_user.username).to eq("generated_username2")
      end

      it "should not generate a username if it's passed in the parameter" do
        expect {
          params[:username] = "not_generated"
          post user_registration_url, params: { user: params }
        }.to change(User, :count).by(1)

        created_user = User.last
        expect(created_user.username).to eq("not_generated")
      end
    end

    context 'when the user is valid' do
      it 'sends the welcome email' do
        post user_registration_url(params: { user: attributes_for(:user, email: "sends.email@example.com") })

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to include("sends.email@example.com")
      end
    end

    context 'when the user is not valid' do
      it 'does not send the welcome email' do
        post user_registration_url(params: { user: attributes_for(:user, email: 'inva@') })

        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    it "should sanitize the parameters" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123",
            display_name: "Did",
            username: "did",
            foo: "bar"
          }
        }
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.email).to eq("test@example.com")
      expect(user.display_name).to eq("Did")
      expect(user.username).to eq("did")
      expect(user.respond_to?(:foo)).to be false
    end
  end

  describe "PATCH #update" do
    let(:update_params) {
      {
        email: "updated@example.com",
        password: "12345678",
        password_confirmation: "12345678",
        username: "updated",
        current_password: "Password1!"
      }
    }

    before do
      @user = create(:user)
      sign_in @user, scope: :user
    end

    it "should update email and require confirmation" do
      old_email = @user.email
      patch user_registration_url, params: { user: update_params }
      expect(response).to have_http_status(303)

      @user.reload

      expect(@user.pending_reconfirmation?).to be true
      expect(@user.unconfirmed_email).to eq("updated@example.com")
      expect(@user.email).to eq(old_email)

      @user.confirm
      @user.reload

      expect(@user.email).to eq("updated@example.com")
    end

    it "should update username" do
      patch user_registration_url, params: { user: update_params }
      expect(response).to have_http_status(303)
      @user.reload
      expect(@user.username).to eq("updated")
    end

    it "should not cause uniqueness constraint on username if username is the same" do
      patch user_registration_url, params: {
        user: {
          username: "customer",
          current_password: "Password1!"
        }
      }

      expect(response).to have_http_status(303)
      @user.reload
      expect(@user.username).to eq("customer")
    end

    it "should sanitizes parameters" do
      patch user_registration_url, params: { user: { **update_params, foo: :bar } }
      expect(response).to have_http_status(303)
      expect(@user.respond_to?(:email)).to be true
      expect(@user.respond_to?(:username)).to be true
      expect(@user.respond_to?(:password)).to be true
      expect(@user.respond_to?(:password_confirmation)).to be true
      expect(@user.respond_to?(:current_password)).to be true
      expect(@user.respond_to?(:foo)).to be false
    end
  end
end
