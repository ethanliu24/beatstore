# frozen_string_literakl: true

module Ui
  module Modal
    class HeaderComponent < ApplicationComponent
      def initialize(title: "")
        @title = title
      end

      private

      attr_reader :title
    end
  end
end
