# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: current_or_guest_user.id
    end
  end

  let(:user) { create(:user) }

  describe "#current_or_guest_user" do
    it "returns current_user if logged in" do
      allow(controller).to receive(:current_user).and_return(user)
      get :index

      expect(response.body).to eq(user.id.to_s)
    end

    it "returns guest_user when no current_user" do
      allow(controller).to receive(:current_user).and_return(nil)

      expect(controller).to receive(:guest_user).and_call_original
      get :index

      user = User.find(response.body)

      expect(user.guest?).to be(true)
    end

    it "destroys guest user when logging in" do
      guest = create(:guest)
      user = create(:user)

      allow(controller).to receive(:current_user).and_return(user)
      session[:guest_user_id] = guest.id

      expect {
        get :index
      }.to change(User, :count).by(-1)

      expect(session[:guest_user_id]).to be_nil
      expect(response.body).to eq(user.id.to_s)
    end
  end

  describe "transfer_guest_to_user" do
    it "transfers cart and order informations after signing up a new account from a anonymous account" do
      guest = create(:guest)
      cart = create(:cart, user: guest)
      cart_item = create(:cart_item, cart:)
      order = create(:order, user: guest)
      order_item = create(:order_item, order:)
      transaction = create(:payment_transaction, order:)

      user = create(:user)
      cart_user = create(:cart, user:)
      _cart_item_user = create(:cart_item, cart: cart_user, license: create(:license, title: "T"))
      order_user = create(:order, user:)
      _order_item_user = create(:order_item, order: order_user)
      _transaction_user = create(:payment_transaction, order: order_user)

      allow(controller).to receive(:guest_user).and_return(guest)
      allow(controller).to receive(:current_user).and_return(user)
      session[:guest_user_id] = guest.id

      expect {
        get :index
      }.to change(User, :count).by(-1)

      expect(user.cart.cart_items).to include(cart_item)
      expect(user.cart.cart_items.count).to eq(2)
      expect(user.orders.find(order.id).order_items).to include(order_item)
      expect(user.orders.find(order.id).payment_transaction).to eq(transaction)
      expect(Cart.find_by(id: cart.id)).to be_nil
      expect(User.find_by(id: guest.id)).to be_nil
    end

    it "does not transfer the same track with same license" do
      track = create(:track)
      license = create(:license)

      guest = create(:guest)
      create(:cart_item, cart: create(:cart, user: guest), product: track, license:)
      user = create(:user)
      cart_item_user = create(:cart_item, cart: create(:cart, user:), product: track, license:)

      allow(controller).to receive(:guest_user).and_return(guest)
      allow(controller).to receive(:current_user).and_return(user)
      session[:guest_user_id] = guest.id

      expect(guest.cart.cart_items.count).to eq(1)
      expect(user.cart.cart_items.count).to eq(1)

      expect {
        get :index
      }.to change(User, :count).by(-1)

      expect(user.cart.cart_items.count).to eq(1)
      expect(user.cart.cart_items.first).to eq(cart_item_user)
      expect(guest.cart.cart_items.count).to eq(0)
    end
  end

  describe "#new_policies_for_user" do
    let(:version_struct) { Struct.new(:tos, :privacy, :cookies) }

    it "returns all versions when the user has not accepted any policies yet" do
      current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.0")

      allow(controller).to receive(:current_or_guest_user).and_return(user)
      allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

      expect(controller.new_policies_for_user).to eq({
        terms_of_service: "test-2.0",
        privacy: "test-1.1",
        cookies: "test-1.0"
      })
    end

    it "returns only the specific policies that have changed" do
      user.legal_policies_acceptance.update(
        tos_version: "test-1.0", privacy_version: "test-1.1", cookies_version: "test-1.0"
      )
      current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.0")

      allow(controller).to receive(:current_or_guest_user).and_return(user)
      allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

      expect(controller.new_policies_for_user).to eq({ terms_of_service: "test-2.0" })
    end

    it "returns an empty hash when the user is fully up to date" do
      allow(controller).to receive(:current_or_guest_user).and_return(user)

      expect(controller.new_policies_for_user).to eq({})
    end

    it "works correctly for guest users" do
      current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.0")
      guest = create(:guest)
      guest.legal_policies_acceptance.update(
        tos_version: "test-1.0", privacy_version: "test-1.1", cookies_version: "test-1.0"
      )


      allow(controller).to receive(:current_or_guest_user).and_return(guest)
      allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

      expect(controller.new_policies_for_user).to include(terms_of_service: "test-2.0")
    end
  end

  describe "#accept_latest_policies!" do
    let(:version_struct) { Struct.new(:tos, :privacy, :cookies) }

    before do
      allow(controller).to receive(:current_or_guest_user).and_return(user)
    end

    it "executes the service and updates the database when policies are pending" do
      user.legal_policies_acceptance.update(
        tos_version: "test-1.0", privacy_version: "test-1.0", cookies_version: "test-1.0"
      )

      acceptance = user.reload.legal_policies_acceptance.reload
      current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.5")

      allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

      controller.accept_latest_policies!

      expect(acceptance.tos_version).to eq("test-2.0")
      expect(acceptance.privacy_version).to eq("test-1.1")
      expect(acceptance.cookies_version).to eq("test-1.5")
    end

    it "does not trigger a service execution or update when already up to date" do
      expect(Users::UpdateAcceptedLegalPoliciesService).not_to receive(:new)

      controller.accept_latest_policies!
    end
  end
end
