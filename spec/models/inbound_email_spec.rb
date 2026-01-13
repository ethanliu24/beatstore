# frozen_string_literal: true

require "rails_helper"

RSpec.describe InboundEmail, type: :model do
  describe "associations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
  end

  context "foreign key behavior" do
    let!(:user) { create(:user) }
    let(:email_data) {
      {
        name: "Diddy",
        email: "email@example.com",
        subject: "Urgently need baby oil",
        message: "yo twin can i borrow like 1000 bottles of baby oil"
      }
    }
  end
end
