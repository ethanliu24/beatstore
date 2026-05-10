# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::LegalPoliciesAcceptance, type: :model do
  it { should belong_to(:user).required }

  describe "validations" do
    let(:user) { create(:user) }
    let(:acceptance) { user.legal_policies_acceptance }

    it "is invalid without a user" do
      record = described_class.new(user: nil)
      expect(record).not_to be_valid
      expect(record.errors[:user]).to be_present
    end

    describe "#timestamps_cannot_move_backwards" do
      let(:initial_time) { Time.zone.parse("2026-05-10 10:00:00") }

      before do
        travel_to initial_time do
          acceptance.update!(
            tos_accepted_at: Time.current,
            tos_version: "v1.0"
          )
        end
      end

      it "is invalid when updating a timestamp to be earlier than the current value" do
        acceptance.tos_accepted_at = initial_time - 1.minute

        expect(acceptance).not_to be_valid
        expect(acceptance.errors[:tos_accepted_at]).to include(/cannot be updated to a time earlier/)
      end

      it "is valid when updating a timestamp to be later than the current value" do
        acceptance.tos_accepted_at = initial_time + 1.hour

        expect(acceptance).to be_valid
      end

      it "is valid when the timestamp is unchanged" do
        acceptance.tos_version = "v1.1"

        expect(acceptance).to be_valid
      end
    end

    describe "uniqueness" do
      it "enforces one record per user" do
        duplicate = described_class.new(user: user)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include("has already been taken")
      end
    end
  end
end
