# frozen_string_literal: true

require "rails_helper"

RSpec.describe MissionControl::Jobs, type: :request do
  describe "get admin/jobs" do
    it "should let admin visit the page" do
      user = create(:admin)
      sign_in user, scope: :user

      get admin_mission_control_jobs_path

      expect(response).to have_http_status(:ok)
    end

    it "should not let customers visit the page" do
      user = create(:user)
      sign_in user, scope: :user

      get admin_mission_control_jobs_path

      expect(response).to redirect_to(root_path)
    end

    it "should not let guests visit the page" do
      user = create(:guest)
      sign_in user, scope: :user

      get admin_mission_control_jobs_path

      expect(response).to redirect_to(root_path)
    end
  end
end
