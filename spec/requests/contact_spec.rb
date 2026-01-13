require 'rails_helper'

RSpec.describe ContactsController, type: :request do
  describe "#new" do
    it "returns http success" do
      get contact_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:email_data) {
      {
        name: "diddy",
        email: "example@email.com",
        subject: "need baby oil urgently",
        message: "yo twin i needa thousand bottles of baby oil"
      }
    }

    it "creates a inbound email record" do
      expect {
        post contact_url(format: :turbo_stream), params: { inbound_email: email_data }
      }.to change(InboundEmail, :count).by(1)

      email = InboundEmail.last

      expect(response).to have_http_status(:success)
      expect(email.name).to eq("diddy")
      expect(email.email).to eq("example@email.com")
      expect(email.subject).to eq("need baby oil urgently")
      expect(email.message).to eq("yo twin i needa thousand bottles of baby oil")
    end

    it "should not create a inbound email record if params not valid" do
      expect {
        email_data[:email] = nil
        post contact_url(format: :turbo_stream), params: { inbound_email: email_data }
      }.to change(InboundEmail, :count).by(0)

      expect(response).to have_http_status(:ok)
    end
  end
end
