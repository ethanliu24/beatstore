# frozen_string_literal

RSpec.shared_examples Commentable do
  let(:user) { create(:user) }

  before do
    raise ArgumentError, "Create an entity of a commentable object named <entity>" unless defined?(entity)
  end

  it { should have_many(:comments) }

  it "should delete all comments associated with it" do
    create(:comment, entity:, user:)
    create(:comment, entity:, user:)

    expect(entity.comments.size).to eq(2)

    entity.destroy!

    expect(entity.comments.size).to eq(0)
  end

  describe "#undiscarded_comments" do
    it "should not return discarded comments" do
      comment = create(:comment, entity:)

      comment.discard!
      comment.reload
      entity.reload

      expect(entity.undiscarded_comments.count).to eq(0)
    end
  end

  describe "#num_comments" do
    it "returns the correct number of comments" do
      create(:comment, entity:)

      expect(entity.reload.num_comments).to eq(1)
    end

    it "returns 0 if no comments" do
      expect(entity.num_comments).to eq(0)
    end
  end
end
