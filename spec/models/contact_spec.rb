# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contact, type: :model do
  describe "associations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
    it { is_expected.to belong_to(:user).optional }
  end

  context "foreign key behavior" do
    let!(:user) { create(:user) }
    let(:contact_data) {
      {
        name: "Diddy",
        email: "email@example.com",
        subject: "Urgently need baby oil",
        message: "yo twin can i borrow like 1000 bottles of baby oil"
      }
    }

    describe "when user is deleted" do
      it "nullifies the user_id on associated free_downloads" do
        contact = Contact.create!(user:, **contact_data)

        expect { user.destroy }.to change {
          contact.reload.user_id
        }.from(user.id).to(nil)

        expect(Contact.exists?(contact.id)).to be true
      end
    end
  end
end
