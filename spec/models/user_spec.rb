require 'ostruct'
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations for User model" do
    it { should validate_presence_of(:display_name) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should have_many(:hearts) }
    it { should have_many(:track_plays) }
    it { should have_many(:comments) }
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

  describe "hearted_tracks association" do
    it "returns tracks liked by the user" do
      track1 = build(:track)
      track2 = build(:track)
      track3 = build(:track)
      create(:track_heart, user: user, track: track1)
      create(:track_heart, user: user, track: track2)

      expect(user.hearted_tracks).to include(track1, track2)
      expect(user.hearted_tracks).not_to include(track3)
    end
  end

  describe "comments association" do
    let(:user) { create(:user) }

    it "should remove all comment the user commented when account is deleted" do
      t1 = create(:track)
      t2 = create(:track)
      _c1 = create(:comment, entity: t1, user: user)
      _c2 = create(:comment, entity: t2, user: user)

      expect(user.comments.size).to eq(2)
      expect(t1.comments.size).to eq(1)
      expect(t2.comments.size).to eq(1)

      user.destroy!

      expect(t1.comments.size).to eq(0)
      expect(t2.comments.size).to eq(0)
    end
  end

  describe "comments_interactions associate" do
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }
    let(:track) { create(:track) }

    it "should destroy all comments and interactions created by the user when account is deleted" do
      comment = create(:comment, entity: track, user:)
      interaction_1 = create(:comment_interaction, comment:, user:)

      expect(user.comment_interactions.size).to eq(1)
      expect(Comment::Interaction.count).to eq(1)
      expect(interaction_1.user).to be(user)

      user.destroy!

      expect(Comment::Interaction.count).to eq(0)
    end

    it "should nullify all user's interaction user_id where the comment is not create by the user when account is deleted" do
      comment = create(:comment, entity: track, user: admin)
      interaction = create(:comment_interaction, comment:, user:)

      expect(user.comment_interactions.size).to eq(1)
      expect(interaction.user).to be(user)

      user.destroy!
      interaction.reload

      expect(comment.user_id).to be(admin.id)
      expect(interaction.user_id).to be_nil
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

    it "should successfully destroy user account and nullify its play and hearts" do
      user = create(:user)
      track = create(:track)
      heart = create(:track_heart, track_id: track.id, user_id: user.id)
      play = create(:track_play, track_id: track.id, user_id: user.id)

      expect { user.destroy }.to change { User.count }.by(-1)

      heart.reload
      play.reload

      expect(heart.user_id).to be_nil
      expect(play.user_id).to be_nil
      expect(heart.track_id).to eq(track.id)
      expect(play.track_id).to eq(track.id)
    end
  end
end
