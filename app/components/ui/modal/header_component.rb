# frozen_string_literakl: true

module Ui
  module Modal
    class HeaderComponent < ApplicationComponent
      def initialize(title: "", size: :lg)
        @title = title
        @size_class = resolve_size_class(size)
      end

      private

      attr_reader :title, :size_class

      def resolve_size_class(size)
        case size
        when :xs
          "text-[0.8rem]"
        when :sm
          "text-base"
        when :md
          "text-lg"
        else
          "text-xl"
        end
      end
    end
  end
end
