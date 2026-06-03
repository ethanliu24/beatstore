# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderFulfillmentJob, type: :job do
  let(:fulfillment_input) do
    FulfillOrderService::Input.build_from_stripe_checkout_session(
      order: create(:order),
      session: build(:stripe_checkout_session_completed_event).data.object
    )
  end

  describe "#perform_now" do
    it "calls fulfillment service when the input is an instance of FulfillOrderService::Input" do
      allow(FulfillOrderService).to receive(:call)

      described_class.perform_now(
        fulfillment_input: fulfillment_input
      )

      expect(FulfillOrderService).to have_received(:call).with(
        input: fulfillment_input
      )
    end

    it "raises an ArgumentError when the input is not an instance of FulfillOrderService::Input" do
      expect {
        described_class.perform_now(fulfillment_input: "invalid")
      }.to raise_error(ArgumentError)
    end
  end

  describe "#performs_later" do
    it "enqueues the job and the serializer is working" do
      expect {
        OrderFulfillmentJob.perform_later(fulfillment_input:)
      }.to have_enqueued_job
    end
  end
end
