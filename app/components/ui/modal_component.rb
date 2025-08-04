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
        "max-w-[30vw] max-h-[30vh]"
      when :sm
        "max-w-[40vw] max-h-[40vh]"
      when :md
        "max-w-[60vw] max-h-[60vh]"
      when :xl
        "max-w-[80vw] max-h-[80vh]"
      else
        "max-w-[95vw] max-h-[95vh]"
      end
    end
  end
end
