# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::PurchasesController, type: :request do
  describe "GET /users/purchases" do
    let(:user) { create(:user) }
    let(:other_user) { create(:admin) }

    before do
      sign_in user, scope: :user
    end

    it "returns order items from completed orders" do
      completed_order = create(:order, user:)
      pending_order = create(:order, user:)
      item1 = create(:order_item, order: completed_order)
      _item2 = create(:order_item, order: pending_order)

      completed_order.update!(status: Order.statuses[:completed])

      get users_purchases_path

      expect(response).to have_http_status(:ok)
      expect(assigns(:purchases)).to match_array([ item1 ])
    end

    it "excludes other users' purchases" do
      other_order = create(:order, user: other_user)
      _foreign_item = create(:order_item, order: other_order)
      other_order.update!(status: Order.statuses[:completed])

      get users_purchases_path

      expect(assigns(:purchases)).to be_empty
    end

    it "orders purchases by order creation desc" do
      older_order = create(:order, user:, created_at: 2.days.ago)
      newer_order = create(:order, user:, created_at: 1.hour.ago)
      old_item = create(:order_item, order: older_order)
      new_item = create(:order_item, order: newer_order)

      older_order.update!(status: Order.statuses[:completed])
      newer_order.update!(status: Order.statuses[:completed])

      get users_purchases_path

      expect(assigns(:purchases)).to eq([ new_item, old_item ])
    end
  end
end
