# frozen_string_literakl: true

module Ui
  module Dropdown
    class LinkComponent < ApplicationComponent
      def initialize(url:, text:, icon:, icon_size:, gap: 4, classes: "")
        @url = url
        @text = text
        @icon_name = icon
        @icon_size = icon_size
        @gap = gap
        @classes = classes
      end

      private

      attr_reader :url, :text, :icon_name, :classes

      def icon_size
        "w-#{@icon_size} h-#{@icon_size} aspect-square"
      end

      def gap
        "gap-#{@gap}"
      end
    end
  end
end
