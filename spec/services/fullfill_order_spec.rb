# frozen_string_literal: true

require "rails_helper"

RSpec.describe FulfillOrderService::Input, type: :model do
  let(:user) { create(:user) }
  let(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:) }

  subject(:input) {
    described_class.new(
      order:,
      customer_email: "customer@example.com",
      customer_name: "John Doe",
      amount_cents: 2000,
      currency: "USD",
      stripe_charge_id: "cs_test_123"
    )
  }

  describe "validations" do
    it { should validate_presence_of(:order) }
    it { should allow_value("customer@example.com").for(:customer_email) }
    it { should_not allow_value("invalid-email").for(:customer_email) }
    it { should validate_presence_of(:customer_name) }
    it {
      should validate_numericality_of(:amount_cents)
        .only_integer
        .is_greater_than_or_equal_to(0)
    }
    it { should validate_presence_of(:currency) }
    it { should validate_length_of(:currency).is_equal_to(3) }
  end

  describe "#build_from_stripe_checkout_session" do
    let(:event) { build_event }
    let(:session) { event.data.object }

    subject(:input) {
      described_class.build_from_stripe_checkout_session(
        order: order,
        session: session
      )
    }

    it "builds an input from the checkout session" do
      expect(input.order.id).to eq(order.id)
      expect(input.transaction).to eq(transaction)
      expect(input.user).to eq(user)

      expect(input.customer_email).to eq("email@example.com")
      expect(input.customer_name).to eq("Customer")
      expect(input.amount_cents).to eq(9999)
      expect(input.currency).to eq("usd")
      expect(input.stripe_charge_id).to eq("cs_test_123")
    end

    it "is valid" do
      expect(input).to be_valid
    end

    private

    def build_event(
      type: "checkout.session.completed",
      obj_id: "cs_test_123",
      customer_email: "email@example.com",
      customer_name: "Customer",
      amount_total: 9999,
      currency: "usd"
    )
      Stripe::Event.construct_from(
        id: "123",
        type:,
        data: {
          object: {
            id: obj_id,
            customer_details: {
              email: customer_email,
              name: customer_name
            },
            amount_total:,
            currency:
          }
        }
      )
    end
  end
end

RSpec.describe FulfillOrderService, type: :service do
end
