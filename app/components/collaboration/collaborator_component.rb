# frozen_string_literal: true

module Collaboration
  class CollaboratorComponent < ApplicationComponent
    def initialize(collaborator:)
      @collaborator = collaborator
    end

    private

    attr_reader :collaborator
  end
end
