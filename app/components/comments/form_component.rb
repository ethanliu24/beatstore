# frozen_string_literal: true

module Comments
  class FormComponent < ViewComponent::Base
    def initialize(entity:, current_user:)
      @entity_id = entity.id
      @entity_class = entity.class.name
      @current_user = current_user
    end

    private

    attr_reader :entity_id, :entity_class, :current_user
  end
end
