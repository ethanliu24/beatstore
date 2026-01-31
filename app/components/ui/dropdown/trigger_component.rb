# frozen_string_literakl: true

module Ui
  module Dropdown
    class TriggerComponent < ApplicationComponent
      # Possible trigger actions: click, hover
      def initialize(id:, classes: "", data: {}, type: "button")
        @id = "#{id}-dropdown-toggle"
        @classes = classes
        @type = type
        @data = data.merge({ dropdown_manager_target: "trigger" })
      end

      private

      attr_reader :id, :classes, :data, :type
    end
  end
end
