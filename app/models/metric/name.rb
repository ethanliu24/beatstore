# frozen_string_literal: true

require "set"

module Metric
  class Name
    TEST = "test"

    class << self
      def is_defined?(name)
        defined_names.include?(name)
      end

      private

      def defined_names
        @defined_names ||= Set.new(
          Names.constants.map { |const_name| Names.const_get(const_name) }
        )
      end
    end
  end
end
