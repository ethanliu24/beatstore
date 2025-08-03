require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :request do
  let!(:user) { create(:user, email: "customer@email.com") }

  describe "POST #create" do
    it "should check whether email exists" do
      post user_confirmation_path, params: { user: { email: "does.not.exist@email.com " } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t("authentication.email_does_not_exist"))
    end
  end
end
