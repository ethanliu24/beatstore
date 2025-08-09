# frozen_string_literakl: true

module Ui
  module Dropdown
    class TriggerComponent < ApplicationComponent
      def initialize(id:, classes: "", data: {}, type: "button")
        @id = "#{id}-dropdown-toggle"
        @classes = classes
        @type = type
        @data = { dropdown_placement: "bottom-end" }
          .merge(data)
          .merge({ dropdown_toggle: id })
      end

      private

      attr_reader :id, :classes, :data, :type
    end
  end
end
