# frozen_string_literal: true

module Ui
  class AccordianComponent < ApplicationComponent
    renders_one :summary
    renders_one :body
  end
end
