# frozen_string_literakl: true

module Ui
  module Modal
    class FooterComponent < ApplicationComponent
      renders_one :primary_action
      renders_many :secondary_actions

      def initialize(cancel_label: "", size: :md)
        @cancel_label = cancel_label
        @size_class = resolve_size_class(size)
      end

      private

      attr_reader :cancel_label, :size_class

      def resolve_size_class(size)
        case size
        when :sm
          "text-sm"
        when :md
          "text-md"
        else
          "text-lg"
        end
      end
    end
  end
end
