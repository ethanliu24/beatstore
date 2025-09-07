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

  describe "mutability" do
    context "order is pending" do
      it "should not allow any updates to the columns" do
        expect { order_item.update!(unit_price_cents: 5000) }.to raise_error(ActiveRecord::RecordNotSaved)
        expect(order_item.errors[:base]).to include("Cannot modify order item details other than attaching files")
      end

      it "should allow file attachment" do
        order_item.files.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
          filename: "tagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        expect(order_item.files.attached?).to be(true)
        expect(order_item.files.first.filename.to_s).to eq("tagged_mp3.mp3")
      end

      it "should allow order items to be associated with an order" do
        oi = create(:order_item, order:)
        order.reload

        expect(order.order_items.count).to eq(2)
        expect(order.order_items.last).to eq(oi)
        expect(oi.order.id).to eq(order.id)
      end
    end

    context "order is completed" do
      before { order.update!(status: Order.statuses[:completed]) }

      it "should not allow column changes" do
        expect {
          order_item.update!(quantity: 2)
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed")
      end

      it "should not allow file attachment" do
        expect {
          order_item.files.attach(
            io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
            filename: "tagged_mp3.mp3",
            content_type: "audio/mpeg"
          )
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed")
      end

      it "should not allow new associations to order" do
        order_item = build(:order_item, order:)
        expect { order_item.save! }.to raise_error(ActiveRecord::RecordNotSaved)
        expect(order_item.errors[:base]).to include("Couldn't create order item as associated order's transaction has completed or failed")
      end
    end

    context "order has failed" do
      before { order.update!(status: Order.statuses[:failed]) }

      it "should not allow column changes" do
        expect {
          order_item.update!(quantity: 2)
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed")
      end

      it "should not allow file attachment" do
        expect {
          order_item.files.attach(
            io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
            filename: "tagged_mp3.mp3",
            content_type: "audio/mpeg"
          )
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "OrderItem is immutable after order is completed or failed")
      end

      it "should not allow new associations to order" do
        order_item = build(:order_item, order:)
        expect { order_item.save! }.to raise_error(ActiveRecord::RecordNotSaved)
        expect(order_item.errors[:base]).to include("Couldn't create order item as associated order's transaction has completed or failed")
      end
    end

    context "destroying" do
      it "raises an error for destroy" do
        expect { order_item.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord, "OrderItems are immutable")
      end
    end
  end
end
