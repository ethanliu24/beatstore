# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user:) }
  let(:track) { create(:track) }
  subject { build(:cart_item, cart:, product: track) }

  describe "associations" do
    it { should belong_to(:cart).required }
    it { should belong_to(:license).optional }
    it { should belong_to(:product).optional }
  end

  describe "validations" do
    it "allows valid product_type" do
      cart_item = build(:cart_item, product: build(:track))
      expect(cart_item).to be_valid
    end

    it "rejects invalid product_type" do
      subject.product_type = "Invalid"

      expect { subject.valid? }.to raise_error(NameError)
    end

    it "should not allow two same items in a single cart" do
      license = create(:license)
      create(:cart_item, cart:, product: track, license:)
      dup = build(:cart_item, cart:, product: track, license:)

      expect(dup).not_to be_valid
    end
  end

  describe "#available?" do
    it "should be true if license and product are both defined" do
      cart_item = create(:cart_item)

      expect(cart_item.available?).to be(true)
    end

    it "should be false if license or product is missing" do
      cart_item = create(:cart_item, product: nil, license: nil)

      expect(cart_item.available?).to be(false)
    end

    it "should be false if license is discarded" do
      track = create(:track)
      license = create(:license)
      cart_item = create(:cart_item, product: track, license:)

      track.discard!
      track.reload
      license.discard!
      license.reload

      expect(cart_item.available?).to eq(false)
    end
  end

  describe "#valid_product_types" do
    it "returns Track as a valid type" do
      expect(CartItem.valid_product_types).to include("Track")
    end
  end

  describe "#available?" do
    let(:cart) { create(:cart) }

    it "should return true if nothing makes the item unavailable" do
      item = create(:cart_item, cart:)

      expect(item.available?).to be(true)
    end

    it "should return false if product or license is nil" do
      item1 = create(:cart_item, cart:, product: nil)
      item2 = create(:cart_item, cart:, license: nil)

      expect(item1.available?).to be(false)
      expect(item2.available?).to be(false)
    end

    it "should return false if track is unavailable" do
      track = create(:track, is_public: false)
      item = create(:cart_item, cart:, product: track)

      expect(item.available?).to be(false)
    end
  end
end
