require 'rails_helper'

RSpec.describe ContactsController, type: :request do
  describe "#show" do
    # it "returns http success" do
    #   get contact_url
    #   expect(response).to have_http_status(:success)
    # end
  end

  describe "#create" do
    let(:user) { create(:user) }
    let(:email_data) {
      {
        name: "diddy",
        email: "example@email.com",
        subject: "need baby oil urgently",
        message: "yo twin i needa thousand bottles of baby oil"
      }
    }

    before do
      sign_in user, scope: :user
    end

    it "creates a contact record" do
      expect {
        post contact_url(format: :turbo_stream), params: { inbound_email: email_data }
      }.to change(InboundEmail, :count).by(1)

      email = InboundEmail.last

      expect(response).to have_http_status(:success)
      expect(email.name).to eq("diddy")
      expect(email.email).to eq("example@email.com")
      expect(email.subject).to eq("need baby oil urgently")
      expect(email.message).to eq("yo twin i needa thousand bottles of baby oil")
      expect(email.user.id).to eq(user.id)
    end
  end
end
