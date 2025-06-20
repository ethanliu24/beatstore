require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations for User model" do
    it { should validate_presence_of(:display_name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should have_many(:hearts) }
    it { should validate_presence_of(:role) }
    it { should define_enum_for(:role).with_values([ :customer, :admin ]) }

    context "password format" do
      it "is valid" do
        user.password = "12345678"
        user.password_confirmation = "12345678"
        expect(user).to be_valid
      end

      it "is invalid if too short" do
        user.password = user.password_confirmation = "1234567"
        expect(user).to be_invalid
      end
    end
  end

  describe "default values on model creation" do
    it "sets default role to customer" do
      user.save!
      expect(user.role).to eq("customer")
    end
  end

  describe 'hearted_tracks association' do
    it 'returns tracks liked by the user' do
      track1 = build(:track)
      track2 = build(:track)
      track3 = build(:track)
      create(:heart, user: user, track: track1)
      create(:heart, user: user, track: track2)

      expect(user.hearted_tracks).to include(track1, track2)
      expect(user.hearted_tracks).not_to include(track3)
    end
  end
end
