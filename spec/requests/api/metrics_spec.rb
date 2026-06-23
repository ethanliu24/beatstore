# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::MetricsController, type: :request do
  let(:window) { WindowSize::ONE_DAY }

  context "admin" do
    let(:user) { create(:admin) }

    before do
      sign_in user, scope: :user
    end

    it "should let admins access stripe_checkout_intent" do
      get api_metrics_stripe_checkout_intent_path(window:)
      expect(response).to have_http_status(:ok)
      expect(assigns[:window]).to eq(window)
    end

    it "should let admins access stripe_one_time_payment" do
      get api_metrics_stripe_one_time_payment_path(window:)
      expect(response).to have_http_status(:ok)
      expect(assigns[:window]).to eq(window)
    end
  end

  shared_examples "should not let non admins visit" do
    it "#stripe_checkout_intent" do
      get api_metrics_stripe_checkout_intent_path(window:)
      expect(response).to have_http_status(:not_found)
    end

    it "#stripe_one_time_payment" do
      get api_metrics_stripe_one_time_payment_path(window:)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "user is customer" do
    let!(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    include_examples "should not let non admins visit"
  end

  context "user is guest" do
    let!(:user) { create(:guest) }

    before do
      sign_in user, scope: :user
    end

    include_examples "should not let non admins visit"
  end
end
