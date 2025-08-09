# frozen_string_literal: true

module Ui
  module Filter
    class ChipComponent < ApplicationComponent
      def initialize(title:, label:, data:, close_action:, render: true)
        @title = title
        @label = label
        @data = data
        @close_action = close_action
        @render = render
      end

      private

      attr_reader :title, :label, :data, :close_action, :render

      def chip_id
        "#{@label}-chip"
      end
    end
  end
end
