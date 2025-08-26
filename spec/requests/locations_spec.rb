# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationsController, type: :request do
  it "returns the provinces of a valid country" do
    get location_provinces_url(country: "CA", format: :turbo_stream)

    expect(response).to have_http_status(200)
    expect(response.body).to include("ON")
  end

  it "should not error on an invalid country" do
    get location_provinces_url(country: "invalid", format: :turbo_stream)

    expect(response).to have_http_status(200)
  end
end
