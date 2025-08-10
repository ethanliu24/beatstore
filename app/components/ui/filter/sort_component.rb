# frozen_string_literal: true

module Ui
  module Filter
    class SortComponent < ApplicationComponent
      def initialize(q:, sort_data:)
        @q = q
        @sort_data = sort_data
      end

      private

      attr_reader :q, :sort_data
    end
  end
end
