# frozen_string_literal: true

module Ui
  module Filter
    class SearchBarComponent < ApplicationComponent
      renders_one :submit_button
      renders_one :clear_button

      def initialize(form:, query:, placeholder:)
        @form = form
        @query = query
        @placeholder = placeholder
      end

      private

      attr_reader :form, :query, :placeholder
    end
  end
end
