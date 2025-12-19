# frozen_string_literal: true

module Ui
  class TooltipComponent < ApplicationComponent
    renders_one :body

    def initialize(anchor_id:, position:)
      @anchor = anchor_id
      @position = position
    end

    private

    attr_reader :anchor_id, :position
  end
end
