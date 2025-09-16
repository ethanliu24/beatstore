# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrdersController, type: :request do
  let(:user) { create(:user) }

  describe "GET /orders" do
    before do
      sign_in user, scope: :user
    end

    it "returns a successful response" do
      get orders_path
      expect(response).to have_http_status(:ok)
    end

    it "assigns the user's orders in descending updated_at order" do
      older_order = create(:order, user:, updated_at: 2.days.ago)
      newer_order = create(:order, user:, updated_at: 1.hour.ago)

      get orders_path

      expect(assigns(:orders)).to eq([ newer_order, older_order ])
    end

    it "does not include other users' orders" do
      other_order = create(:order, user: create(:admin))
      create(:order, user:)

      get orders_path

      expect(assigns(:orders)).not_to include(other_order)
    end
  end
end
