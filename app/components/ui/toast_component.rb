# frozen_string_literal: true

module Ui
  class ToastComponent < ApplicationComponent
    def initialize(type:, message:)
      @type = type.to_sym
      @message = message
    end

    private

    attr_reader :type, :message

    def backgrond_class
      case type
      when :notice
        "bg-[#5dc968] dark:bg-[#55b560]"
      else
        "bg-[#e84235]"
      end
    end

    def icon_name
      case type
      when :notice
        "circle-check"
      else
        "alert-circle"
      end
    end
  end
end
