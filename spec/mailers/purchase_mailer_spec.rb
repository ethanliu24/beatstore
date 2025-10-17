# frozen_string_literal: true

require "rails_helper"

RSpec.describe PurchaseMailer, type: :mailer do
  let!(:user) { create(:user) }
  let!(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:, customer_name: "Puff Diddy",
    customer_email: "email@gmail.com", stripe_receipt_url: "www.stripe.com") }

  describe "#purchase_complete" do
    it "sends email to both user and transaction customer when transaction has a customer email" do
      mail = PurchaseMailer.with(user: user, order: order).purchase_complete

      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)

      sent_email = ActionMailer::Base.deliveries.last
      expect(sent_email.to.sort).to eq([ user.email, transaction.customer_email ].compact.sort)
      expect(sent_email.subject).to eq("Thank you for your purchase")
    end

    it "sends email only to the user when transaction customer email is missing" do
      transaction.update(customer_email: nil)
      mail = PurchaseMailer.with(user: user, order: order).purchase_complete

      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)

      sent_email = ActionMailer::Base.deliveries.last
      expect(sent_email.to).to eq([ user.email ])
      expect(sent_email.subject).to eq("Thank you for your purchase")
    end
  end
end
