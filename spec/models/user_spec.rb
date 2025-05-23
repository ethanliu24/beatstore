require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations for User model" do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }

    it { should validate_presence_of(:role) }
    it { should define_enum_for(:role).with_values([ :customer, :admin ]) }

    context "password format" do
      it "is valid with a strong password" do
        user.password = "Password1!"
        expect(user).to be_valid
      end

      it "is invalid without an uppercase letter" do
        user.password = user.password_confirmation = "password1!"
        expect(user).to be_invalid
      end

      it "is invalid without a digit" do
        user.password = user.password_confirmation = "Password!"
        expect(user).to be_invalid
      end

      it "is invalid without a special character" do
        user.password = user.password_confirmation = "Password1"
        expect(user).to be_invalid
      end

      it "is invalid if too short" do
        user.password = user.password_confirmation = "Passw0!"
        expect(user).to be_invalid
      end
    end
  end

  describe "default values on model creation" do
    it "sets default role to customer" do
      user.save!
      expect(user.role).to eq("customer")
    end

    it "sets default profile_picture to empty string" do
      user.save!
      expect(user.profile_picture).to eq("")
    end
  end
end
