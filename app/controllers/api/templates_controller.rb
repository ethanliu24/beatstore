# frozen_string_literal: true

class Api::TemplatesController < ApplicationController
  def show
    unless current_user && current_user.admin?
      redirect_to root_path
    end

    contract_type = params[:contract_type]

    render json: {
      template: Rails.configuration.templates[:contracts][contract_type]
    }
  end
end
