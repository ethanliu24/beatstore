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
  end

  describe "#performs_later" do
    it "enqueues the job and the serializer is working" do
      expect {
        OrderFulfillmentJob.perform_later(fulfillment_input:)
      }.to have_enqueued_job
    end
  end

  describe "error handling" do
    it "retries the job on OrderFulfillmentFailedError" do
      allow(FulfillOrderService).to receive(:call)
        .and_raise(FulfillOrderService::OrderFulfillmentFailedError)

      expect {
        described_class.perform_now(fulfillment_input:)
      }.to retry_on(FulfillOrderService::OrderFulfillmentFailedError)
    end

    it "stops retrying after the maximum attempts limit" do
      allow(described_class).to receive(:executions).and_return(5)

      expect {
        job.perform_now(fulfillment_input:)
      }.to raise_error(FulfillOrderService::OrderFulfillmentFailedError)
    end
    it "raises an ArgumentError when the input is not an instance of FulfillOrderService::Input" do
      expect {
        described_class.perform_now(fulfillment_input: "invalid")
      }.to discard_on(ArgumentError)
    end
  end
end
