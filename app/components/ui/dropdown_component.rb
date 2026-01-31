# frozen_string_literal: true

module Ui
  class DropdownComponent < ApplicationComponent
    renders_one :trigger_button, Dropdown::TriggerComponent
    renders_many :sections

    # Possible popsitions:
    #   - bottom-start
    #   - bottom-end
    #   - top-start
    #   - top-end
    #   - left-start
    #   - left-end
    #   - right-start
    #   - right-end
    def initialize(id:, position: "bottom-end", classes: "", data: {})
      @id = id
      @position = position
      @classes = classes
      @data = data.merge({ dropdown_manager_target: "menu" })
    end

    private

    attr_reader :id, :position, :classes, :data
  end
end
