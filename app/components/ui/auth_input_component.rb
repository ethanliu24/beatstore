# frozen_string_literal: true

module Ui
  class AuthInputComponent < ViewComponent::Base
    def initialize(form:, resource:, field:, label:, type:, options: {})
      @form = form
      @resource = resource
      @field = field
      @label = label
      @options = options
    end

    private

    attr_reader :form, :resource, :field, :label, :options

    def field_type
      case @field
      when :email
        :email_field
      when :password
        :password_field
      else
        :text_field
      end
    end

    def errors
      @resource.errors.full_messages_for(@field)
    end
  end
end
