# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user:) }
  let(:track) { create(:track) }
  subject { build(:cart_item, cart:, product: track) }

  describe "associations" do
    it { should belong_to(:cart).required }
    it { should belong_to(:license).required }
    it { should belong_to(:product) }
  end

  describe "validations" do
    it { should validate_presence_of(:license) }

    it "allows valid product_type" do
      cart_item = build(:cart_item, product: build(:track))
      expect(cart_item).to be_valid
    end

    it "rejects invalid product_type" do
      subject.product_type = "Invalid"
      expect { subject.valid? }.to raise_error(NameError)
    end
  end

  describe ".valid_product_types" do
    it "returns Track as a valid type" do
      expect(CartItem.valid_product_types).to include("Track")
    end
  end
end
