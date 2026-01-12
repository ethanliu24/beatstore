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
    let(:contact_data) {
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
        post contact_url(format: :turbo_stream), params: { contact: contact_data }
      }.to change(Contact, :count).by(1)

      contact_info = Contact.last

      expect(response).to have_http_status(:success)
      expect(contact_info.name).to eq("diddy")
      expect(contact_info.email).to eq("example@email.com")
      expect(contact_info.subject).to eq("need baby oil urgently")
      expect(contact_info.message).to eq("yo twin i needa thousand bottles of baby oil")
      expect(contact_info.user.id).to eq(user.id)
    end
  end
end
