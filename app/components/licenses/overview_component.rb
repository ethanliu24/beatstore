# frozen_string_literal: true

module Licenses
  class OverviewComponent < ApplicationComponent
    def initialize(license:, overview:)
    end

    private

    attr_accessor license:, overview:
  end
end
