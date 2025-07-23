require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:track) { create(:track) }
  let(:user) { create(:user) }
  subject(:comment) { build(:comment, entity: track, user: user) }

  it { should validate_presence_of(:content) }
  it { should belong_to(:user).optional(false) }

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
end
