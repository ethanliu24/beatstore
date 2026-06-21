# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MetricsController, type: :request, admin: true do
  describe "#index" do
    it "should let admin visit the page" do
      get admin_metrics_url
      expect(response).to have_http_status(:ok)
      expect(assigns[:window]).to eq(WindowSize::ONE_DAY)
    end

    it "should set window size to the param passed in" do
      get admin_metrics_url(window: WindowSize::ONE_HOUR)
      expect(assigns[:window]).to eq(WindowSize::ONE_HOUR)
    end
  end

  describe "#dashboards" do
    it "returns a successful Turbo Stream response and assigns default window size if not passed in" do
      get dashboards_admin_metrics_url(format: :turbo_stream),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(assigns[:window]).to eq(WindowSize::ONE_DAY)
    end

    it "returns a successful Turbo Stream response and assigns window size in params" do
      get dashboards_admin_metrics_url(format: :turbo_stream),
      params: { window: WindowSize::ONE_HOUR },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(assigns[:window]).to eq(WindowSize::ONE_HOUR)
    end
  end

  describe "admin paths authorization test", authorization_test: true do
    it "only allows admin at #show" do
      get admin_metrics_url
      expect(response).to redirect_to(root_path)
    end

    it "only allows admin at #update_quick_stats" do
      get dashboards_admin_metrics_url
      expect(response).to redirect_to(root_path)
    end
  end
end
