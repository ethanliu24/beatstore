require 'rails_helper'

RSpec.describe Comment::Interaction, type: :model do
  let(:user) { create(:user) }
  let(:track) { create(:track) }
  let(:comment) { create(:comment, entity: track, user: user) }
  subject(:interaction) { build(:comment_interaction, comment:, user:) }

  it { should belong_to(:comment).optional(false) }
  it { should belong_to(:user).optional(true) }
  it { should validate_presence_of(:interaction_type) }

  it "should allow the following interaction type" do
    [ "like", "dislike" ].each do |interaction_type|
      subject.interaction_type = interaction_type
      expect(subject).to be_valid, "Interaction type #{interaction_type} is not valid"
    end
  end

  it "should only allow one interaction per user" do
    _like = create(:comment_interaction, comment:, user:)
    like_2 = build(:comment_interaction, comment:, user:)
    dislike = build(:comment_interaction, interaction_type: "dislike", comment:, user:)

    expect(comment.liked_by?(user)).to be(true)
    expect(like_2).not_to be_valid
    expect(dislike).not_to be_valid
  end
end
