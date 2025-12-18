# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeDownloadMailer, type: :mailer do
  let(:free_download) { create(:free_download) }

  describe "#download" do
    it "sends email to the customer in the record" do
      mail = FreeDownloadMailer.with(free_download:).download

      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)

      sent_email = ActionMailer::Base.deliveries.last
      expect(sent_email.to).to eq([ free_download.email ])
      expect(sent_email.subject).to eq("Your Download - #{free_download.track.title}")
    end
  end
end
