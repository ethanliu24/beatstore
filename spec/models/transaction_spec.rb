# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cart, type: :model do
  let(:subject) { build(:payment_transaction) }

  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:amount_cents) }
  it { should validate_presence_of(:currency) }

  it { should belong_to(:order) }

  describe "status" do
    it "should allow all defined payment processors" do
      Transaction.statuses.each do |_, status|
        subject.status = status

        expect(subject).to be_valid
      end
    end

    it "should not allow undefined payment processors" do
      expect {
        subject.status = "invalid"
      }.to raise_error(ArgumentError)
    end
  end

  describe "payment_processor" do
    it "should allow all defined payment processors" do
      Transaction.payment_processors.each do |_, payment_processor|
        subject.payment_processor = payment_processor

        expect(subject).to be_valid
      end
    end

    it "should not allow undefined payment processors" do
      expect {
        subject.payment_processor = "invalid"
      }.to raise_error(ArgumentError)
    end
  end
end
