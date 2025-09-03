# frozen_string_literal

require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should belong_to(:user).required }
    it { should have_many(:items) }
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
end
