# frozen_string_literal: true

class OrderFulfillmentJob < ApplicationJob
  queue_as :high

  retry_on FulfillOrderService::OrderFulfillmentFailedError

  discard_on ArgumentError

  def perform(fulfillment_input:)
    unless fulfillment_input.is_a?(FulfillOrderService::Input)
      raise ArgumentError, "fulfillment_input must be a FulfillOrderService::Input"
    end

    FulfillOrderService.call(input: fulfillment_input)
  end
end
