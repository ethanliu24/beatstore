# frozen_string_literal: true

module Licenses
  class LicenseComponent < ApplicationComponent
    def initialize(license:)
      @license = license
    end

    private

    attr_accessor :license
  end
end
