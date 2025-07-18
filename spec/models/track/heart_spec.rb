require 'rails_helper'

RSpec.describe Track::Heart, type: :model do
  describe "associations" do
    it { should belong_to(:user).optional }
    it { should belong_to(:track).optional }
  end

  describe "validations" do
    subject { create(:track_heart) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:track_id) }
  end

  describe "uniqueness constraint" do
    it "does not allow a user to heart the same track more than once" do
      user = create(:user)
      track = create(:track)

      create(:track_heart, user: user, track: track)
      duplicate = build(:track_heart, user: user, track: track)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
  end
end
