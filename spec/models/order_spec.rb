# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:subtotal_cents) }
    it { should validate_numericality_of(:subtotal_cents).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:restrict_with_error) }
  end

  describe "validations" do
    let(:order) { create(:order) }

    it "requires a public_id" do
      order.public_id = nil
      expect(order).not_to be_valid
      expect(order.errors[:public_id]).to include("is required")
    end

    it "public_id follows the correct format" do
      travel_to Time.zone.local(2025, 11, 11, 12, 34, 56) do
        id_regex = /\A#{Order::PUBLIC_ID_PREFIX}_251111123456_[A-Za-z0-9]{#{Order::PUBLIC_ID_SUFFIX_LENGTH}}\z/

        expect(order).to be_valid
        expect(order.public_id).to match(id_regex)
      end
    end
  end

  describe "statuses" do
    subject(:order) { build(:order) }

    it "allows the following statuses" do
      [ "pending", "completed", "failed" ].each do |status|
        subject.status = status
        expect(subject).to be_valid
      end
    end

    it "does not accept invalid statuses" do
      expect {
        subject.status = "invalid"
      }.to raise_error(ArgumentError)
    end
  end

  describe "immutability" do
    let!(:order) { create(:order, user: user) }

    context "when status is pending" do
      it "can update status to completed" do
        expect {
          order.update!(status: Order.statuses[:completed])
        }.to change { order.reload.status }.from(Order.statuses[:pending]).to(Order.statuses[:completed])
      end

      it "can update status to failed" do
        expect {
          order.update!(status: Order.statuses[:failed])
        }.to change { order.reload.status }.from(Order.statuses[:pending]).to(Order.statuses[:failed])
      end

      it "does not allow any column updates other than status updates" do
        expect {
          order.update!(subtotal_cents: 1111)
        }.to raise_error(ActiveRecord::RecordNotSaved)
        order.reload

        expect(order.errors.full_messages).to include("Cannot modify order details other than status")
      end
    end

    context "when status is completed" do
      before { order.update!(status: Order.statuses[:completed]) }

      it "does not allow any updates" do
        expect {
          order.update!(subtotal_cents: 2222)
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "Cannot modify order details once transaction completed or failed")
        expect(order.reload.subtotal_cents).to eq(2000)
      end

      it "does not allow status updates" do
        expect {
          order.update!(status: Order.statuses[:failed])
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "Cannot modify order details once transaction completed or failed")

        expect(order.reload.status).to eq(Order.statuses[:completed])
      end
    end

    context "when status is failed" do
      before { order.update!(status: Order.statuses[:failed]) }

      it "does not allow any updates" do
        expect {
          order.update!(currency: "CAD")
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "Cannot modify order details once transaction completed or failed")
        expect(order.reload.currency).to eq("USD")
      end

      it "does not allow status updates" do
        expect {
          order.update!(status: Order.statuses[:completed])
        }.to raise_error(ActiveRecord::ReadOnlyRecord, "Cannot modify order details once transaction completed or failed")
        expect(order.reload.status).to eq(Order.statuses[:failed])
      end
    end

    context "destroying" do
      it "raises an error for destroy" do
        expect { order.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord, "Orders are immutable")
      end
    end
  end
end
