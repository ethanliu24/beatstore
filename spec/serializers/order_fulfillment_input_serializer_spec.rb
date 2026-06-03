# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderFulfillmentInputSerializer do
  subject(:serializer) { described_class.instance }
  let(:order) { create(:order) }
  let(:session) { build(:stripe_checkout_session_completed_event).data.object }
  let(:input) {
    FulfillOrderService::Input.build_from_stripe_checkout_session(order:, session:)
  }

  describe "#serialize?" do
    it "should return true if input is an instance of FulfillOrderService::Input" do
      expect(serializer.serialize?(input)).to eq(true)
    end

    it "should return false if input is not a FulfillOrderService::Input" do
      expect(serializer.serialize?(String)).to eq(false)
    end
  end

  describe "#serialize" do
    it "serializes the input into a hash" do
      result = serializer.serialize(input)

      expect(result["order_id"]).to eq(order.id)
      expect(result["customer_email"]).to eq("email@example.com")
      expect(result["customer_name"]).to eq("Customer")
      expect(result["amount_cents"]).to eq(9999)
      expect(result["currency"]).to eq("usd")
      expect(result["stripe_charge_id"]).to eq("co_test_123")
    end
  end

  describe "#deserialize" do
    it "rebuilds a FulfillOrderService::Input from the hash" do
      hash = serializer.serialize(input)
      result = serializer.deserialize(hash)

      expect(result.is_a?(FulfillOrderService::Input)).to eq(true)
      expect(result.order.id).to eq(order.id)
      expect(result.customer_email).to eq("email@example.com")
      expect(result.customer_name).to eq("Customer")
      expect(result.currency).to eq("usd")
      expect(result.stripe_charge_id).to eq("co_test_123")
    end
  end

  describe "#kclass" do
    it "returns the correct class" do
      expect(serializer.kclass).to eq(FulfillOrderService::Input)
    end
  end
end
