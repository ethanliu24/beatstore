# frozen_string_literal: true

module Ui
  class FloatingInputComponent < ApplicationComponent
    def initialize(form:, field:, label:, field_type:, id:, input_classes: "", label_classes: "", data: {})
      @form = form
      @field = field
      @label = label
      @field_type = field_type
      @id = id
      @input_classes = input_classes
      @label_classes = label_classes
      @data = data
    end

    private

    attr_reader :form, :field, :label, :field_type, :id, :input_classes, :label_classes, :data
  end
end
