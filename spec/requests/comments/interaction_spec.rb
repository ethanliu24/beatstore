require 'rails_helper'

RSpec.describe Comments::InteractionsController, type: :request do
  let(:user) { create(:user) }
  let(:track) { create(:track) }
  let(:comment) { create(:comment, entity: track, user:) }

  describe "user is authenticated" do
    before do
      sign_in user, scope: :user
    end

    describe "like interactions" do
      context "#like" do
        it "should create a new interaction with current user" do
          expect(user.comment_interactions.size).to eq(0)

          expect {
            post like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(1)

          user.reload
          created_like = Comment::Interaction.last

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_like.id)
        end

        it "should do nothing if current user already liked comment" do
          expect {
            post like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(1)

          created_like = Comment::Interaction.last

          expect {
            post like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          user.reload

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_like.id)
        end

        it "should delete dislike interaction if current user disliked the comment already" do
          dislike = create(:comment_dislike, comment:, user:)

          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(dislike.id)

          expect {
            post like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          user.reload
          created_like = Comment::Interaction.last

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_like.id)
          expect(Comment::Interaction.where(interaction_type: "dislike").size).to eq(0)
        end
      end

      context "#unlike" do
        it "should remove the like interaction if there is one" do
          like = create(:comment_like, comment:, user:)

          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(like.id)

          expect {
            delete like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(-1)

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(0)
        end

        it "should do nothing if current user doesn't have any likes on comment" do
          expect {
            delete like_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(0)
        end
      end
    end

    describe "dislike interactions" do
      context "#dislike" do
        it "should create a new interaction with current user" do
          expect(user.comment_interactions.size).to eq(0)

          expect {
            post dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(1)

          user.reload
          created_dislike = Comment::Interaction.last

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_dislike.id)
        end

        it "should do nothing if current user already disliked comment" do
          expect {
            post dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(1)

          created_dislike = Comment::Interaction.last

          expect {
            post dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          user.reload

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_dislike.id)
        end

        it "should delete like interaction if current user liked the comment already" do
          like = create(:comment_like, comment:, user:)

          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(like.id)

          expect {
            post dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          user.reload
          created_dislike = Comment::Interaction.last

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(created_dislike.id)
          expect(Comment::Interaction.where(interaction_type: "like").size).to eq(0)
        end
      end

      context "#undislike" do
        it "should remove the dislike interaction if there is one" do
          dislike = create(:comment_dislike, comment:, user:)

          expect(user.comment_interactions.size).to eq(1)
          expect(user.comment_interactions.first.id).to eq(dislike.id)

          expect {
            delete dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(-1)

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(0)
        end

        it "should do nothing if current user doesn't have any dislikes on comment" do
          expect {
            delete dislike_comment_url(comment)
          }.to change(Comment::Interaction, :count).by(0)

          expect(response).to have_http_status(:no_content)
          expect(user.comment_interactions.size).to eq(0)
        end
      end
    end
  end

  describe "user is not authenticated" do
    it "should redirect user when liking" do
      expect {
        post like_comment_url(comment)
      }.to change(Comment::Interaction, :count).by(0)

      expect(response).to have_http_status(302)
    end

    it "should redirect user when disliking" do
      expect {
        post dislike_comment_url(comment)
      }.to change(Comment::Interaction, :count).by(0)

      expect(response).to have_http_status(302)
    end

    it "should redirect user when unliking" do
      expect {
        delete like_comment_url(comment)
      }.to change(Comment::Interaction, :count).by(0)

      expect(response).to have_http_status(302)
    end

    it "should redirect user when undisliking" do
      expect {
        delete dislike_comment_url(comment)
      }.to change(Comment::Interaction, :count).by(0)

      expect(response).to have_http_status(302)
    end
  end
end
