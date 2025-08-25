# frozen_string_literal: true

class LocationsController < ApplicationController
  def provinces
    country = ISO3166::Country[params[:country]]
    @provinces = (country&.subdivisions || {}).map { |k, v| [ v["name"], k ] }

    respond_to do |format|
      format.turbo_stream
    end
  end
end
