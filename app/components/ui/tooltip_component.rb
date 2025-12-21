# frozen_string_literal: true

module Ui
  class TooltipComponent < ApplicationComponent
    renders_one :body

    def initialize(anchor_id:, position: :top, color_pallet: nil)
      @anchor_id = anchor_id
      @position = position  # valid values: top, left, right, bottom, defaults to top
      @bg_color = get_bg_color(color_pallet:)
      @text_color = get_text_color(color_pallet:)
    end

    private

    attr_reader :anchor_id, :position, :bg_color, :text_color

    def get_bg_color(color_pallet:)
      case color_pallet
      when "accent"
        "accent"
      when "default"
        "tooltip-bg"
      else
        "tooltip-bg"
      end
    end

    def get_text_color(color_pallet:)
      case color_pallet
      when "accent"
        "white"
      when "default"
        "tooltip-text"
      else
        "tooltip-text"
      end
    end
  end
end
