# frozen_string_literal

require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should belong_to(:user).required }
    it { should have_many(:cart_items) }
  end

  describe "dependent behavior" do
    it "destroys associated cart_items when destroyed" do
      user = create(:user)
      cart = create(:cart, user:)
      create(:cart_item, cart:)

      expect { cart.destroy }.to change { CartItem.count }.by(-1)
    end
  end

  describe "#has_item?" do
    it "should return true if a cart item exists" do
      cart = create(:cart)
      license = create(:license)
      track = create(:track)
      create(:cart_item, cart:, license:, product: track)

      expect(cart.has_item?(license_id: license.id, product_type: Track.name, product_id: track.id)).to be(true)
    end

    it "should return true if a cart item exists" do
      cart = create(:cart)
      license = create(:license)
      track = create(:track)

      expect(cart.has_item?(license_id: license.id, product_type: Track.name, product_id: track.id)).to be(false)
    end
  end

  describe "#total_cents" do
    it "should return the correct total" do
      cart = create(:cart)
      license1 = create(:license, price_cents: 1000)
      license2 = create(:license, title: "L2", price_cents: 1234)
      track = create(:track)
      create(:cart_item, cart:, product: track, license: license1)
      create(:cart_item, cart:, product: track, license: license2)

      expect(cart.total_price_cents).to eq(2234)
    end

    it "should not have floating point errors" do
      cart = create(:cart)
      license1 = create(:license, price_cents: 0001)
      license2 = create(:license, title: "L2", price_cents: 0002)
      track = create(:track)
      create(:cart_item, cart:, product: track, license: license1)
      create(:cart_item, cart:, product: track, license: license2)

      expect(cart.total_price_cents).to eq(0003)
    end
  end
end
