# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::LegalPoliciesAcceptance, type: :model do
  it { should belong_to(:user).required }

  describe "validations" do
    it "is invalid without a user" do
      record = described_class.new(user: nil)

      expect(record).not_to be_valid
      expect(record.errors[:user]).to be_present
    end

    it "allows a valid record" do
      user = create(:user)

      record = described_class.new(user: user)

      expect(record).to be_valid
    end

    it "enforces uniqueness of user_id" do
      user = create(:user)

      described_class.create!(user: user)

      duplicate = described_class.new(user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "raises DB error when user_id is duplicated" do
      user = create(:user)

      described_class.create!(user: user)

      expect {
        described_class.create!(user: user)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
