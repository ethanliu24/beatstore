# frozen_string_literal: true

module Ui
  class ModalComponent < ApplicationComponent
    renders_one :header, Modal::HeaderComponent
    renders_one :body
    renders_one :footer, Modal::FooterComponent

    def initialize(size: :lg)
      @size_class = resolve_size_class(size)
    end

    private

    attr_reader :size_class

    def resolve_size_class(size)
      case size
      when :xs
        "max-w-1/3 max-h-1/3 max-sm:max-w-[90vw]"
      when :sm
        "max-w-md max-h-2/5 max-sm:max-w-[90vw]"
      when :md
        "max-w-xl max-h-4/5 max-sm:max-w-[90vw]"
      when :xl
        "max-w-4xl max-h-[95vh] max-md:max-w-[90vw]"
      else
        "max-w-2xl max-h-[80vh] max-md:max-w-[90vw]"
      end
    end
  end
end
