# frozen_string_literal: true

require "set"

module Metrics
  class Name
    TEST = "test"
    STRIPE_ONE_TIME_PAYMENT = "stripe_one_time_payment"

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
