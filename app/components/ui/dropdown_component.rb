# frozen_string_literal: true

module Ui
  class DropdownComponent < ApplicationComponent
    renders_one :trigger_button, Dropdown::TriggerComponent
    renders_many :sections

    def initialize(id:, classes: "", data: {})
      @id = id
      @classes = classes
      @data = data.merge({ dropdown_manager_target: "menu" })
    end

    private

    attr_reader :id, :classes, :data
  end
end
