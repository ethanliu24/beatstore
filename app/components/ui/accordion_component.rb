# frozen_string_literal: true

module Ui
  class AccordionComponent < ApplicationComponent
    renders_one :summary
    renders_one :body

    def initialize(open: false)
      @open = open
    end

    attr_reader :open
  end
end
