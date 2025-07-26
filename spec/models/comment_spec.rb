require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:track) { create(:track) }
  let(:user) { create(:user) }
  subject(:comment) { build(:comment, entity: track, user: user) }

  it { should validate_presence_of(:content) }
  it { should belong_to(:user).optional(false) }
  it { should have_many(:interactions).dependent(:destroy) }

  context "content legnth" do
    it "is invalid if description is blank" do
      subject.content = ""
      expect(subject).not_to be_valid
      expect(subject.errors.details[:content]).to include(hash_including(error: :blank))
    end

    it "is valid if description is less than or equal to 200 characters" do
      subject.content = "a" * Comment::MAX_COMMENT_LENGTH
      expect(subject).to be_valid
    end

    it "is invalid if description is longer than 200 characters" do
      subject.content = "a" * (Comment::MAX_COMMENT_LENGTH + 1)
      expect(subject).not_to be_valid
      expect(subject.errors.details[:content]).to include(hash_including(error: :too_long))
    end
  end

  it "belongs to a polymorphic entity" do
    expect(subject.entity).to eq(track)
    expect(subject.entity_type).to eq("Track")
    expect(subject.entity_id).to eq(track.id)
  end

  it "should validate precense of entity" do
    comment = build(:comment, entity: nil, user: create(:user))
    expect(comment).not_to be_valid
    expect(comment.errors[:entity]).to include("must exist")
  end

  it "should delete all of its interactions when deleted" do
    comment = create(:comment, entity: track, user: user)
    interaction_1 = create(:comment_interaction, comment: comment, user: user)
    interaction_2 = create(:comment_interaction, comment: comment, user: user)

    expect(comment.interactions.count).to eq(2)

    comment.destroy!

    expect(Comment.find_by(id: interaction_1.id)).to be_nil
    expect(Comment.find_by(id: interaction_2.id)).to be_nil
  end

  describe "interaction methods" do
    let!(:like) { create(:comment_interaction, comment:, user:) }
    let!(:dislike) { create(:comment_interaction, interaction_type: "dislike", comment:, user:) }

    it "#likes should return all liked interactions" do
      expect(comment.likes.size).to eq(1)
      expect(comment.likes.first.id).to eq(like.id)
    end

    it "#dislikes should return all disliked interactions" do
      expect(comment.dislikes.size).to eq(1)
      expect(comment.dislikes.first.id).to eq(dislike.id)
    end

    it "#liked_by? should return whether the user liked it or not" do
      user_2 = create(:admin)

      expect(comment.liked_by?(user)).to be(true)
      expect(comment.liked_by?(user_2)).to be(false)
    end

    it "#liked_by? should return whether the user liked it or not" do
      user_2 = create(:admin)

      expect(comment.liked_by?(user)).to be(true)
      expect(comment.liked_by?(user_2)).to be(false)
    end
  end
end
