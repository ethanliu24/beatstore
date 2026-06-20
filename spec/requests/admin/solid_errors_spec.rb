# frozen_string_literal: true

require "rails_helper"

class TestSolidErrorsController < Admin::BaseController
  def index
    head :ok
  end
end

RSpec.describe SolidErrors, type: :request do
  before do
    allow_any_instance_of(SolidErrors::ErrorsController).to receive(:index) do |controller|
      controller.head :ok
    end
  end

  describe "get admin/jobs" do
    it "should let admin visit the page" do
      user = create(:admin)
      sign_in user, scope: :user

      get admin_solid_errors_path

      expect(response).to have_http_status(:ok)
    end

    it "should not let customers visit the page" do
      user = create(:user)
      sign_in user, scope: :user

      get admin_solid_errors_path

      expect(response).to have_http_status(:not_found)
    end

    it "should not let guests visit the page" do
      user = create(:guest)
      sign_in user, scope: :user

      get admin_solid_errors_path

      expect(response).to have_http_status(:not_found)
    end
  end
end
