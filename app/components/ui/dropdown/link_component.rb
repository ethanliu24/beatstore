# frozen_string_literakl: true

module Ui
  module Dropdown
    class LinkComponent < ApplicationComponent
      def initialize(url:, text:, icon:, icon_size:, classes: "", text_classes: "", data: {})
        @url = url
        @text = text
        @icon_name = icon
        @icon_size = icon_size
        @classes = classes
        @data = data
        @text_classes = text_classes
      end

      private

      attr_reader :url, :text, :icon_name, :classes, :text_classes, :data

      def icon_size
        "w-#{@icon_size} h-#{@icon_size} aspect-square"
      end
    end
  end
end
