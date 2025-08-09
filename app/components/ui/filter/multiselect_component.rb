# frozen_string_literal: true

module Ui
  module Filter
    class MultiselectComponent < ApplicationComponent
      def initialize(label:, query:, options:, values:, container_data: {}, checkbox_data: {}, render: true)
        @label = label
        @query = query
        # options and values should be parallel, where options[i] corresponds to values[i]
        @options = options  # The text to show for the selection options
        @values = values  # The actual value for the selection options
        @container_data = container_data
        @checkbox_data = checkbox_data
        @render = render
      end

      def render?
        @render
      end

      private

      attr_reader :id, :query, :options, :values, :container_data, :checkbox_data

      def checkbox_id(option)
        "#{@label}-selection-#{snake_case(option)}"
      end
    end
  end
end
