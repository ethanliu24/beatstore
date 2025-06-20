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
        post user_registration_path, params: params
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
  end

  # describe "PUT #update" do
  #   let(:user) { create(:user) }

  #   before do
  #     sign_in user
  #   end

  #   context "with valid parameters" do
  #     let(:valid_update_params) do
  #       {
  #         user: {
  #           email: "updated@example.com",
  #           current_password: "password123"
  #         }
  #       }
  #     end

  #     it "updates the user" do
  #       put :update, params: valid_update_params
  #       user.reload

  #       expect(user.email).to eq("updated@example.com")
  #       expect(response).to have_http_status(:redirect)
  #     end
  #   end

  #   context "with invalid parameters" do
  #     let(:invalid_update_params) do
  #       {
  #         user: {
  #           email: "invalid_email",
  #           current_password: "wrong_password"
  #         }
  #       }
  #     end

  #     it "does not update the user" do
  #       put :update, params: invalid_update_params
  #       user.reload

  #       expect(user.email).not_to eq("invalid_email")
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end
  #   end
  # end
end
