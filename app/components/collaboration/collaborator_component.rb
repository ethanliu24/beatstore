# frozen_string_literal: true

module Collaboration
  class CollaboratorComponent < ApplicationComponent
    def initialize(form:, collaborator: nil)
      @form = form
      @collaborator = collaborator || Collaboration::Collaborator.new
    end

    private

    attr_reader :form, :collaborator
  end
end
