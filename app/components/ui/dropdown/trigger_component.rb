# frozen_string_literakl: true

module Ui
  module Dropdown
    class TriggerComponent < ApplicationComponent
      def initialize(id:, classes: "", data: {}, type: "button")
        @id = "#{id}-dropdown-toggle"
        @classes = classes
        @type = type
        @data = data
          .merge({
            dropdown_manager_target: "trigger",
            action: "click->dropdown-manager#toggle"
          })
      end

      private

      attr_reader :id, :classes, :data, :type
    end
  end
end
