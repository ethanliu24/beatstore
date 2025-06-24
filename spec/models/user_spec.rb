require 'ostruct'
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
    it { should have_one_attached(:profile_picture) }

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

    context "biography length" do
      it "allows biography within the limit" do
        user = build(:user, biography: "a" * User::BIOGRAPHY_LENGTH)
        expect(user).to be_valid
      end

      it "does not allow biography over the limit" do
        user = build(:user, biography: "a" * (User::BIOGRAPHY_LENGTH + 1))
        expect(user).not_to be_valid
        expect(user.errors.details[:biography]).to include(hash_including(error: :too_long))
      end

      it "allows biography to be blank or nil" do
        user = build(:user, biography: "")
        expect(user).to be_valid
        user = build(:user, biography: nil)
        expect(user).to be_valid
      end
    end

    context "display name length" do
      it "allows display name within the limit" do
        user = build(:user, display_name: "a" * User::DISPLAY_NAME_LENGTH)
        expect(user).to be_valid
      end

      it "does not allow display name over the limit" do
        user = build(:user, display_name: "a" * (User::DISPLAY_NAME_LENGTH + 1))
        expect(user).not_to be_valid
        expect(user.errors.details[:display_name]).to include(hash_including(error: :too_long))
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

  describe "omniauth" do
    before do
      allow(Faraday).to receive(:get).and_return(
        instance_double(Faraday::Response,
          success?: true,
          body: "fake-image-data",
          headers: { "content-type" => "image/jpeg" }
        )
      )
    end

    let(:auth) {
      OpenStruct.new(
        provider: "provider",
        uid: "123456",
        info: OpenStruct.new(
          email: "test@example.com",
          name: "Test",
          image: "https://example.com/avatar.jpg"
        )
      )
    }

    it "#from_omniauth creates new user if email doesn't exist" do
      expect {
        User.from_omniauth(auth)
      }.to change(User, :count).by(1)
    end

    it "#from_omniauth binds user if email already exists" do
      expect {
        User.from_omniauth(auth)
      }.to change(User, :count).by(1)

      expect {
        User.from_omniauth(auth)
      }.to change(User, :count).by(0)

      user = User.last
      expect(user.provider).to eq("provider")
      expect(user.uid).to eq("123456")
      expect(user.email).to eq("test@example.com")
      expect(user.display_name).to eq("Test")
      expect(user.profile_picture).to be_attached
    end
  end
end
