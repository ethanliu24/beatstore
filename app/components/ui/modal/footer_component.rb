# frozen_string_literakl: true

module Ui
  module Modal
    class FooterComponent < ApplicationComponent
      renders_one :primary_action
      renders_one :secondary_action

      def initialize(cancel_label: "")
        @cancel_label = cancel_label
      end

      private

      attr_reader :cancel_label
    end
  end
end
