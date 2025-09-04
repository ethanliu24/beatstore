# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartItemsController, type: :request do
  let(:track) { create(:track) }
  let(:license) { create(:license) }

  describe "POST #create" do
    let(:valid_params) do
      {
        product_id: track.id,
        product_type: "Track",
        license_id: license.id,
        quantity: 1
      }
    end

    it "should create a cart item for user" do
      user = create(:user)
      sign_in user, scope: :user

      expect {
        post cart_items_url(format: :turbo_stream), params: { cart_item: valid_params }
      }.to change(CartItem, :count).by(1)

      item = user.cart.items.first

      expect(response).to have_http_status(200)
      expect(user.cart.items.count).to eq(1)
      expect(item.product).to eq(track)
      expect(item.license).to eq(license)
      expect(item.quantity).to eq(1)
    end

    it "should let a guest user add an item to cart" do
      expect {
        expect {
          post cart_items_url(format: :turbo_stream), params: { cart_item: valid_params }
        }.to change(CartItem, :count).by(1)
      }.to change(User, :count).by(1)

      user = User.last
      item = user.cart.items.first

      expect(response).to have_http_status(200)
      expect(user.guest?).to be(true)
      expect(user.cart.items.count).to eq(1)
      expect(item.product).to eq(track)
      expect(item.license).to eq(license)
      expect(item.quantity).to eq(1)
    end

    it "should not add an item if it's already in cart" do
      user = create(:user)
      sign_in user, scope: :user
      create(:cart_item, cart: user.cart, license:, product: track)

      expect {
        post cart_items_url(format: :turbo_stream), params: { cart_item: valid_params }
      }.to change(CartItem, :count).by(0)

      expect(response).to have_http_status(200)
    end
  end

  describe "DELETE #destroy" do
    before do
      @user = create(:user)
      sign_in @user, scope: :user

      @item = create(:cart_item, cart: @user.cart, license:, product: track)
    end

    it "delets the specified cart item" do
      expect {
        delete cart_item_url(@item, format: :turbo_stream)
      }.to change(CartItem, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(CartItem.find_by(id: @item.id)).to be_nil
    end

    it "delets the specified cart item for a guest user" do
      sign_out @user

      post cart_items_url(format: :turbo_stream), params: { cart_item:
        {
          product_id: track.id,
          product_type: "Track",
          license_id: license.id,
          quantity: 1
        }
      }

      item = CartItem.last

      expect(response).to have_http_status(200)
      expect {
        delete cart_item_url(item, format: :turbo_stream)
      }.to change(CartItem, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(CartItem.find_by(id: item.id)).to be_nil
    end
  end
end
