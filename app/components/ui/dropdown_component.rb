# frozen_string_literal: true

module Ui
  class DropdownComponent < ApplicationComponent
    renders_one :trigger_button, Dropdown::TriggerComponent
    renders_many :sections

    # Possible popsitions:
    #   - bottom-start, bottom-end, bottom
    #   - top-start, top-end, top
    #   - left-start, left-end, left
    #   - right-start, right-end, right
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
