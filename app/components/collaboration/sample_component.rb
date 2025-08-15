# frozen_string_literal: true

module Collaboration
  class SampleComponent < ApplicationComponent
    def initialize(sample:)
      @sample = sample
    end

    private

    attr_reader :sample
  end
end
