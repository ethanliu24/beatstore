# frozen_string_literal: true

require "rails_helper"

RSpec.describe FulfillOrderService::Input, type: :model do
  let(:user) { create(:user) }
  let(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:) }

  subject(:input) {
    described_class.new(
      order:,
      customer_email: "customer@example.com",
      customer_name: "John Doe",
      amount_cents: 2000,
      currency: "USD"
    )
  }

  describe "validations" do
    it { should validate_presence_of(:order) }
    it { should allow_value("customer@example.com").for(:customer_email) }
    it { should_not allow_value("invalid-email").for(:customer_email) }
    it { should validate_presence_of(:customer_name) }
    it {
      should validate_numericality_of(:amount_cents)
        .only_integer
        .is_greater_than_or_equal_to(0)
    }
    it { should validate_presence_of(:currency) }
    it { should validate_length_of(:currency).is_equal_to(3) }
  end

  describe "#build_from_stripe_checkout_session" do
    let(:event) { build_event }
    let(:session) { event.data.object }

    subject(:input) {
      described_class.build_from_stripe_checkout_session(
        order: order,
        session: session
      )
    }

    it "builds an input from the checkout session" do
      expect(input.order.id).to eq(order.id)
      expect(input.transaction).to eq(transaction)
      expect(input.user).to eq(user)

      expect(input.customer_email).to eq("email@example.com")
      expect(input.customer_name).to eq("Customer")
      expect(input.amount_cents).to eq(9999)
      expect(input.currency).to eq("usd")
    end

    it "is valid" do
      expect(input).to be_valid
    end

    private

    def build_event(
      type: "checkout.session.completed",
      obj_id: "cs_test_123",
      customer_email: "email@example.com",
      customer_name: "Customer",
      amount_total: 9999,
      currency: "usd"
    )
      build(:stripe_checkout_session_completed_event)
    end
  end
end

RSpec.describe FulfillOrderService, type: :service do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:track) { create(:track_with_files) }
  let(:license) { create(:non_exclusive_license, contract_details: {
    delivers_mp3: true,
    delivers_wav: false,
    delivers_stems: true
  }) }
  let!(:order) { create(:order, user:) }
  let!(:transaction) { create(:payment_transaction, order:) }
  let!(:order_item) { create(
    :order_item,
    order:,
    quantity: 1,
    unit_price_cents: 1000,
    currency: "USD",
    product_type: Track.name,
    product_snapshot: Snapshots::TakeTrackSnapshotService.new(track: track).call,
    license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license: license).call,
    is_immutable: false
  ) }
  let(:event) { build(:stripe_checkout_session_completed_event) }
  let(:session) { event.data.object }

  describe "#call" do
    it "copies files to order item" do
      call_service(order:, session:)
      order.reload

      first_item = order.order_items.first

      # Verify underlying item data state
      expect(first_item.files.attached?).to be(true)
      expect(first_item.files.count).to eq(2)
      expect(first_item.files.first.blob.filename).to eq("untagged_mp3.mp3")
      expect(first_item.files.first.content_type).to eq("audio/mpeg")
      expect(first_item.files.last.blob.filename).to eq("track_stems.zip")
      expect(first_item.files.last.content_type).to eq("application/zip")

      expect(first_item.preview_image.filename.to_s).to eq("oi_preview_cover_photo.png")
      expect(first_item.preview_image.content_type).to eq("image/png")
      expect(first_item.is_immutable).to be(true)
    end

    it "updates transaction with customer data" do
      call_service(order:, session:)
      order.reload

      current_transaction = order.payment_transaction

      expect(current_transaction.status).to eq(Transaction.statuses[:completed])
      expect(current_transaction.customer_email).to eq("email@example.com")
      expect(current_transaction.customer_name).to eq("Customer")
      expect(current_transaction.amount_cents).to eq(9999)
      expect(current_transaction.currency).to eq("usd")
    end

    it "marks order as completed" do
      call_service(order:, session:)

      expect(order.status).to eq(Order.statuses[:completed])
    end

    it "sends buyer an email" do
      perform_enqueued_jobs do
        call_service(order:, session:)
      end

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Thank you for your purchase")
    end

    it "raises ArgumentError if input is not valid" do
      expect {
        described_class.call(input: nil)
      }.to raise_error(ArgumentError)
    end

    it "does not process non pending orders" do
      Order.statuses
        .map { |key, status| status }
        .filter { |status| status != Order.statuses[:pending] }
        .each { |status|
          order.update!(status:)
          order.reload

          expect {
            call_service(order:, session:)
          }.to raise_error(FulfillOrderService::OrderAlreadyFulfilledError)
        }
    end

    it "rolls back all changes if an error occurs" do
      allow(order).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        call_service(order:, session:)
      }.to raise_error(FulfillOrderService::OrderFulfillmentFailedError)

      aggregate_failures do
        expect(transaction.reload.status).to eq(Transaction.statuses[:pending])
        expect(order.reload.status).to eq(Order.statuses[:pending])
        order.order_items.each do |item|
          expect(item.files.count).to eq(0)
        end
      end
    end

    it "raises OrderFulfillmentFailedError if something goes wrong" do
      allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError)

      expect {
        call_service(order:, session:)
      }.to raise_error(FulfillOrderService::OrderFulfillmentFailedError)
    end
  end

  private

  def call_service(order:, session:)
    input = FulfillOrderService::Input
      .build_from_stripe_checkout_session(order:, session:)

    described_class.call(input:)
  end
end
