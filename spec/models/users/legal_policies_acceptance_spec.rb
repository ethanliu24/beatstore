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
  end
end
