# frozen_string_literal: true

module Api
  class TemplatesController < ApplicationController
    def get_contract_templates
      unless current_user && current_user.admin?
        redirect_to root_path
        return
      end

      contract_type = params[:contract_type]

      render json: {
        template: Rails.configuration.templates[:contracts][contract_type]
      }
    end
  end
end
