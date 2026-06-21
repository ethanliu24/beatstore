# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::MetricsController, type: :request do
  context "admin" do
    let(:user) { create(:admin) }

    before do
      sign_in user, scope: :user
    end

    it "should let admins access stripe_checkout_intent" do
      get api_metrics_stripe_checkout_intent_path
      expect(response).to have_http_status(:ok)
    end
  end

  shared_examples "should not let non admins visit" do
    it "#stripe_checkout_intent" do
      get api_metrics_stripe_checkout_intent_path
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
