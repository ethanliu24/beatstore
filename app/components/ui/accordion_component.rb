# frozen_string_literal: true

module Ui
  class AccordionComponent < ApplicationComponent
    renders_one :summary
    renders_one :body

    def initialize(expand: false)
      @expand = expand
    end

    attr_reader :expand
  end
end
