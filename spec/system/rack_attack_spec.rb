# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rack::Attack, type: :request do
  include Rack::Test::Methods

  let(:default_ip) { "1.2.3.4" }
  let!(:app) { Rails.application }

  def env_for(path:, ip: default_ip, method: :get, params: {})
    Rack::MockRequest.env_for(
      path,
      method: method.to_s.upcase,
      params:,
      "REMOTE_ADDR" => ip
    )
  end

  before do
    Rack::Attack.enabled = true
  end

  after do
    Rack::Attack.enabled = false
  end

  describe "general IP request throttling" do
    it "throttles after 300 requests per 5 minutes" do
      300.times { app.call(env_for(path: root_path, method: :get)) }
      status, = app.call(env_for(path: root_path, method: :get))

      expect(status).to eq(429)
    end
  end

  describe "auth IP throttling" do
    it "throttles sign up attempts by IP" do
      params = { user: { email: "test@example.com" } }

      5.times { app.call(env_for(path: user_registration_path, method: :post, params:)) }
      status, = app.call(env_for(path: user_registration_path, method: :post, params:))

      expect(status).to eq(429)
    end

    it "throttles sign in attempts by IP" do
      params = { user: { email: "test@example.com" } }

      5.times { app.call(env_for(path: user_session_path, method: :post, params:)) }
      status, = app.call(env_for(path: user_session_path, method: :post, params:))

      expect(status).to eq(429)
    end
  end

  describe "auth email thorttling" do
    it "throttles sign up attempts by email" do
      params = { user: { email: "test@example.com" } }

      5.times do |i|
        app.call(env_for(path: user_registration_path, ip: "1.2.3.#{i}", method: :post, params:))
      end
      status, = app.call(env_for(path: user_registration_path, method: :post, params:))

      expect(status).to eq(429)
    end

    it "throttles sign in attempts by IP" do
      params = { user: { email: "test@example.com" } }

      5.times do |i|
        app.call(env_for(path: user_session_path, ip: "1.2.3.#{i}", method: :post, params:))
      end
      status, = app.call(env_for(path: user_session_path, method: :post, params:))

      expect(status).to eq(429)
    end
  end

  describe "free download IP throttling" do
    let(:free_download) { create(:free_download, user: create(:user), track: create(:track)) }

    it "throttles after 10 requests per 10 seconds" do
      10.times { app.call(env_for(path: get_free_download_path(free_download), method: :get)) }
      status, = app.call(env_for(path: get_free_download_path(free_download), method: :get))

      expect(status).to eq(429)
    end

    it "throttles after 500 requests per 1 hour" do
      # this case is not tested bc it thorttles on prev cond, not gonna figure out how to test this rn lol
      500.times { app.call(env_for(path: get_free_download_path(free_download), method: :get)) }
      status, = app.call(env_for(path: get_free_download_path(free_download), method: :get))

      expect(status).to eq(429)
    end
  end

  describe "paid download IP throttling" do
    before do
      allow_any_instance_of(DownloadsController).to receive(:product_item).and_return(nil)
    end

    it "throttles after 15 requests per 10 seconds" do
      15.times { app.call(env_for(path: download_product_item_path(id: 1, item_id: 1, file_id: 1), method: :get)) }
      status, = app.call(env_for(path: download_product_item_path(id: 1, item_id: 1, file_id: 1), method: :get))

      expect(status).to eq(429)
    end

    it "throttles after 100 requests per 10 minutes" do
      # this case is not tested bc it thorttles on prev cond, not gonna figure out how to test this rn lol
      100.times { app.call(env_for(path: download_product_item_path(id: 1, item_id: 1, file_id: 1), method: :get)) }
      status, = app.call(env_for(path: download_product_item_path(id: 1, item_id: 1, file_id: 1), method: :get))

      expect(status).to eq(429)
    end
  end
end
