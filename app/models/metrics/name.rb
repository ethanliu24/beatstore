# frozen_string_literal: true

require "set"

module Metrics
  class Name
    TEST = "test"
    ORDER_FULFILLMENT_SUCEEDED = "order_fulfillment_succeeded"
    STRIPE_ONE_TIME_PAYMENT = "stripe_one_time_payment"
    STRIPE_CHECKOUT_INTENT = "stripe_checkout_intent"

    class << self
      def is_defined?(name)
        defined_names.include?(name)
      end

      private

      def defined_names
        @defined_names ||= Set.new(
          Name.constants.map { |const_name| Name.const_get(const_name) }
        )
      end
    end
  end
end
