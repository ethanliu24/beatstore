# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  let!(:inbound_email) { create(:inbound_email) }
  let(:mailer) { ContactMailer.with(inbound_email:).contact }

  describe "#contact" do
    it "sends email to both producer email, cc's itself and replies to the customer email" do
      expect(mailer.to).to include(::Credentials::Email.producer_email)
      expect(mailer.to.length).to eq(1)

      expect(mailer.reply_to).to include(inbound_email.email)
      expect(mailer.reply_to.length).to eq(1)

      expect(mailer.cc).to include(::Credentials::Email.domain_email)
      expect(mailer.cc.length).to eq(1)

      expect(mailer.subject).to eq(inbound_email.subject)
    end

    it "includes the customer name and message in the body" do
      body = mailer.body.encoded

      expect(body).to include(inbound_email.name)
      expect(body).to include(inbound_email.message)
    end
  end
end
