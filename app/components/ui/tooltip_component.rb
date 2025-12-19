# frozen_string_literal: true

module Ui
  class TooltipComponent < ApplicationComponent
    renders_one :body

    def initialize(anchor_id:, position:)
      @anchor_id = anchor_id
      @position = position  # valid values: top, left, right, bottom, defaults to top
    end

    private

    attr_reader :anchor_id, :position
  end
end
