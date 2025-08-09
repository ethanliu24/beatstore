# frozen_string_literal: true

module Ui
  module Filter
    class RangeComponent < ApplicationComponent
      def initialize(form:, label:, lb_query:, ub_query:, container_data: {}, range_data: {}, render: true)
        @form = form
        @label = label
        @lowerbound_query = lb_query
        @upperbound_query = ub_query
        @container_data = container_data
        @range_data = range_data
        @render = render
      end

      def render?
        @render
      end

      private

      attr_reader :form, :label, :lowerbound_query, :upperbound_query, :container_data, :range_data
    end
  end
end
