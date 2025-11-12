# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request, admin: true do
  describe "#show" do
    it "returns a successful response and assigns stats" do
      get admin_dashboard_url

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:cum_stats)).to be_a(Hash)
      expect(assigns(:chron_stats)).to be_a(Hash)
    end
  end

  describe "#update_quick_stats" do
    let(:window_size) { WindowSize::ONE_WEEK }

    it "returns a successful Turbo Stream response and assigns stats" do
      get update_quick_stats_admin_dashboard_url(format: :turbo_stream),
        params: { window_size: window_size },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(assigns(:cum_stats)).to be_a(Hash)
      expect(assigns(:chron_stats)).to be_a(Hash)
    end
  end

  describe "admin paths authorization test", authorization_test: true do
    it "only allows admin at #show" do
      get admin_dashboard_url
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at #update_quick_stats" do
      get update_quick_stats_admin_dashboard_url, params: { window_size: WindowSize::ONE_MONTH }
      expect(response).to redirect_to(root_path)
    end
  end
end
