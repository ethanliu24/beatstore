# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration::Collaborator, type: :model do
  let(:track) { create(:track) }
  let(:subject) { build(:collaborator, entity: track) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:profit_share) }
    it { is_expected.to validate_presence_of(:publishing_share) }
    it { is_expected.to validate_numericality_of(:profit_share).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_numericality_of(:publishing_share).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_presence_of(:notes).allow_blank }

    it "should be invalid if role is not defined" do
      expect { subject.role = "invalid" }.to raise_error(ArgumentError, /invalid/)
    end

    it "should be invalid if profit share is not between 0 and 1" do
      subject.profit_share = -1
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to include("Profit share must be greater than or equal to 0")

      subject.profit_share = 100.01
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to include("Profit share must be less than or equal to 100")
    end

    it "should be invalid if publishing share is not between 0 and 1" do
      subject.publishing_share = -1
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to include("Publishing share must be greater than or equal to 0")

      subject.profit_share = 100.01
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to include("Profit share must be less than or equal to 100")
    end
  end
end
