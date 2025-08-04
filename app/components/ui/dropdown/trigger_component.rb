# frozen_string_literakl: true

module Ui
  module Dropdown
    class TriggerComponent < ApplicationComponent
      def initialize(id:, classes: "", data: {})
        # You should not pass in id if rendering with DropdownComponent
        @id = "#{id}-dropdown-toggle"
        @classes = classes
        @data = { dropdown_placement: "bottom-end" }
          .merge(data)
          .merge({ dropdown_toggle: id })
      end

      private

      attr_reader :id, :classes, :data
    end
  end
end
