# frozen_string_literal: true

require "set"

module Metrics
  class Names
    DEFINED_NAMES = Set.new([]).freeze

    class << self
      def is_defined?(name)
        DEFINED_NAMES.include?(name)
      end
    end
  end
end
