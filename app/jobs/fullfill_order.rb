# frozen_string_literal: true

class OrderFullfillmentJob < ApplicationJob
  queue_as :high

  def perform(fulfillment_input:)
    unless input.is_a?(FulfillOrderService::Input)
      raise ArgumentError, "FullfillOrderService.call input must be a FulfillOrderService::Input"
    end

    FulfillOrderService.call(input: fulfillment_input)
  end
end
