# frozen_string_literal: true

module Admin
  class MetricSectionComponent < ApplicationComponent
    renders_one :charts

    def initialize(title:)
      @title = title
    end

    private

    attr_reader :title
  end
end
