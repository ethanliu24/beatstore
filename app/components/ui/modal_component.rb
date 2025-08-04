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

    def resolve_size_class(size)
      case size
      when :xs
        ""
      when :sm
        ""
      when :md
        ""
      when :xl
        ""
      else
        "max-w-2xl max-h-4/5"
      end
    end
  end
end
