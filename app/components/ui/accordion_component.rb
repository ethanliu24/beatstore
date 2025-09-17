# frozen_string_literal: true

module Ui
  class AccordionComponent < ApplicationComponent
    renders_one :summary
    renders_one :body
  end
end
