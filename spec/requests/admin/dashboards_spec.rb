# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DashboardsController, type: :request, admin: true do
  let(:user) { create(:user, username: "dashboards_controller", email: "dashboards_controller@example.com") }
  let(:order) { create(:order, user:) }

  let!(:play1) { create(:track_play, user:, created_at: 2.hours.ago) }
  let!(:play2) { create(:track_play, user:, created_at: 1.hour.ago) }
  let!(:heart) { create(:track_heart, user:, created_at: 3.hours.ago) }
  let!(:comment1) { create(:comment, user:, created_at: 1.hour.ago) }
  let!(:comment2) { create(:comment, user:, created_at: 10.minutes.ago) }
  let!(:completed_sale1) { create(:payment_transaction, amount_cents: 1500, status: :completed, order:, created_at: 2.hours.ago) }
  let!(:completed_sale2) { create(:payment_transaction, amount_cents: 2500, status: :completed, order:, created_at: 1.hour.ago) }
  let!(:pending_sale) { create(:payment_transaction, amount_cents: 9999, status: :pending, order:, created_at: 1.hour.ago) }
  let!(:free_download1) { create(:free_download, user:, created_at: 1.hour.ago) }
  let!(:free_download2) { create(:free_download, user:, created_at: 2.years.ago) }

  describe "#show" do
    it "returns a successful response and assigns stats" do
      get admin_dashboard_url

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:cum_stats)).to be_a(Hash)
      expect(assigns(:chron_stats)).to be_a(Hash)
    end

    it "computes the correct stats" do
      get admin_dashboard_url

      cum_stats = @controller.view_assigns["cum_stats"]
      expect(cum_stats[:plays]).to eq(2)
      expect(cum_stats[:hearts]).to eq(1)
      expect(cum_stats[:comments]).to eq(2)
      expect(cum_stats[:sales]).to eq(Money.new(4000).format)
      expect(cum_stats[:free_downloads]).to eq(1)

      chron_stats = @controller.view_assigns["chron_stats"]
      expect(chron_stats[:plays].values.sum).to eq(2)
      expect(chron_stats[:hearts].values.sum).to eq(1)
      expect(chron_stats[:comments].values.sum).to eq(2)
      expect(chron_stats[:sales].values.sum).to eq(40.0)
      expect(chron_stats[:free_downloads].values.sum).to eq(1)
    end

    it "computes the correct stats when there's no data" do
      Track::Play.delete_all
      Track::Heart.delete_all
      Comment.delete_all
      Transaction.delete_all
      FreeDownload.delete_all

      get admin_dashboard_url

      cum_stats = @controller.view_assigns["cum_stats"]
      expect(cum_stats[:plays]).to eq(0)
      expect(cum_stats[:hearts]).to eq(0)
      expect(cum_stats[:comments]).to eq(0)
      expect(cum_stats[:sales]).to eq(Money.new(0).format)
      expect(cum_stats[:free_downloads]).to eq(0)

      chron_stats = @controller.view_assigns["chron_stats"]
      expect(chron_stats[:plays]).to eq({})
      expect(chron_stats[:hearts]).to eq({})
      expect(chron_stats[:comments]).to eq({})
      expect(chron_stats[:sales]).to eq({})
      expect(chron_stats[:free_downloads]).to eq({})
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

    it "computes the correct stats" do
      get update_quick_stats_admin_dashboard_url(format: :turbo_stream),
        params: { window_size: window_size },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      cum_stats = @controller.view_assigns["cum_stats"]
      expect(cum_stats[:plays]).to eq(2)
      expect(cum_stats[:hearts]).to eq(1)
      expect(cum_stats[:comments]).to eq(2)
      expect(cum_stats[:sales]).to eq(Money.new(4000).format)
      expect(cum_stats[:free_downloads]).to eq(1)

      chron_stats = @controller.view_assigns["chron_stats"]
      expect(chron_stats[:plays].values.sum).to eq(2)
      expect(chron_stats[:hearts].values.sum).to eq(1)
      expect(chron_stats[:comments].values.sum).to eq(2)
      expect(chron_stats[:sales].values.sum).to eq(40.0)
      expect(chron_stats[:free_downloads].values.sum).to eq(1)
    end

    it "computes the correct stats when there's no data" do
      Track::Play.delete_all
      Track::Heart.delete_all
      Comment.delete_all
      Transaction.delete_all
      FreeDownload.delete_all

      get update_quick_stats_admin_dashboard_url(format: :turbo_stream),
        params: { window_size: window_size },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      cum_stats = @controller.view_assigns["cum_stats"]
      expect(cum_stats[:plays]).to eq(0)
      expect(cum_stats[:hearts]).to eq(0)
      expect(cum_stats[:comments]).to eq(0)
      expect(cum_stats[:sales]).to eq(Money.new(0).format)
      expect(cum_stats[:free_downloads]).to eq(0)

      chron_stats = @controller.view_assigns["chron_stats"]
      expect(chron_stats[:plays]).to eq({})
      expect(chron_stats[:hearts]).to eq({})
      expect(chron_stats[:comments]).to eq({})
      expect(chron_stats[:sales]).to eq({})
      expect(chron_stats[:free_downloads]).to eq({})
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
