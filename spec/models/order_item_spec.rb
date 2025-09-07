# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  let(:order) { create(:order) }
  let!(:order_item) { create(:order_item, order:) }

  it { should belong_to(:order) }
  it { should have_many_attached(:files) }
  it { should validate_presence_of(:product_snapshot) }
  it { should validate_presence_of(:license_snapshot) }
  it { should validate_presence_of(:currency) }
  it { should validate_numericality_of(:unit_price_cents).is_greater_than_or_equal_to(0) }

  describe "validations" do
    it "requires a public_id" do
      order_item.public_id = nil
      expect(order_item).not_to be_valid
      expect(order_item.errors[:public_id]).to include("is required")
    end

    it "allows purchasable products" do
      [ Track.name ].each do |type|
        order_item.product_type = type
        expect(order_item).to be_valid
      end
    end

    it "validates product_type inclusion" do
      order_item.product_type = "invalid"
      expect(order_item).not_to be_valid
      expect(order_item.errors[:product_type]).to include("invalid is not a valid entity type")
    end
  end
end
