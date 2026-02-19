# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartsController, type: :request do
  describe "GET #show" do
    it "should be a valid page for logged in user" do
      user = create(:user)
      sign_in user, scope: :user

      get cart_path

      expect(response).to have_http_status(:ok)
    end

    it "should be a valid page for logged in user" do
      get cart_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE #clear" do
    let(:user) { create(:user) }
    let!(:cart_item) { create(:cart_item, cart: user.cart) }

    before do
      sign_in user, scope: :user
    end

    it "should clear user's cart" do
      expect(user.cart.cart_items.count).to eq(1)

      delete clear_cart_path(format: :turbo_stream)

      expect(response).to have_http_status(:ok)
      expect(user.cart.cart_items.count).to eq(0)
    end
  end
end
