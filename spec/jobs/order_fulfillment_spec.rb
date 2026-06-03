# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderFulfillmentJob, type: :job do
  describe "#perform" do
    let(:fulfillment_input) do
      FulfillOrderService::Input.build_from_stripe_checkout_session(
        order: create(:order),
        session: build(:stripe_checkout_session_completed_event).data.object
      )
    end

    context "when fulfillment_input is a FulfillOrderService::Input" do
      it "calls FulfillOrderService with the input" do
        allow(FulfillOrderService).to receive(:call)

        described_class.perform_now(
          fulfillment_input: fulfillment_input
        )

        expect(FulfillOrderService).to have_received(:call).with(
          input: fulfillment_input
        )
      end
    end

    context "when fulfillment_input is not a FulfillOrderService::Input" do
      it "raises an ArgumentError" do
        expect {
          described_class.perform_now(fulfillment_input: "invalid")
        }.to raise_error(ArgumentError)
      end
    end
  end
end
