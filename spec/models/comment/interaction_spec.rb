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
end
