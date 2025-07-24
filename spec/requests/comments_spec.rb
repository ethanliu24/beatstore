require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let!(:track) { create(:track) }
  let(:params) {
    {
      content: "Comment.",
      entity_type: "Track",
      entity_id: track.id
    }
  }

  describe "current user is logged in" do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    it "should create a comment with the current user" do
      expect {
        post comments_url, params: { comment: params.merge(foo: "bar") }
      }.to change(Comment, :count).by(1)

      comment = Comment.last
      expect(response).to have_http_status(204)
      expect(comment.content).to eq("Comment.")
      expect(comment.entity_type).to eq("Track")
      expect(comment.entity_id).to eq(track.id)
      expect(comment.user_id).to eq(user.id)
      expect(comment.respond_to?(:foo)).to be false
    end

    it "should update a comment's content only made by the current user" do
      expect {
        post comments_url, params: { comment: params }
      }.to change(Comment, :count).by(1)

      comment = Comment.last
      expect(comment.content).to eq("Comment.")
      expect(comment.entity_type).to eq("Track")
      expect(comment.entity_id).to eq(track.id)
      expect(comment.user_id).to eq(user.id)

      put comment_url(comment), params: { comment: { content: "updated", foo: "bar" } }

      comment.reload
      expect(response).to have_http_status(204)
      expect(comment.content).to eq("updated")
      expect(comment.entity_type).to eq("Track")
      expect(comment.entity_id).to eq(track.id)
      expect(comment.user_id).to eq(user.id)
      expect(comment.respond_to?(:foo)).to be false
    end

    it "should throw a 404 error if entity type is invalid" do
      expect {
        post comments_url, params: { comment: params.merge(entity_type: "Invalid") }
      }.to change(Comment, :count).by(0)

      expect(response).to have_http_status(422)
    end

    it "should delete the comment made by the current user" do
      expect {
        post comments_url, params: { comment: params }
      }.to change(Comment, :count).by(1)

      comment = Comment.last
      expect(comment.content).to eq("Comment.")

      expect {
        delete comment_url(comment)
      }.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(204)
    end
  end

  describe "the user taking action is a admin" do
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }
    let!(:comment) { create(:comment, entity: track, user: user) }

    before do
      sign_in admin, scope: :user
    end

    it "should let admin update a comment" do
      put comment_url(comment), params: { comment: { content: "updated by admin" } }

      comment.reload
      expect(response).to have_http_status(204)
      expect(comment.content).to eq("updated by admin")
      expect(comment.entity_type).to eq("Track")
      expect(comment.entity_id).to eq(track.id)
      expect(comment.user_id).to eq(user.id)
    end

    it "should let admin delete a comment" do
      expect {
        delete comment_url(comment)
      }.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(204)
    end
  end

  describe "a user that didn't create the comment" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, email: "comments_other_user@email.com", username: "comments_other_user") }
    let!(:comment) { create(:comment, entity: track, user: user) }

    before do
      sign_in other_user, scope: :user
    end

    it "shuold not be able to update the comment" do
      put comment_url(comment)
      expect(response).to have_http_status(404)
    end

    it "should not be able to delete a comment" do
      expect {
        delete comment_url(comment)
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(404)
    end
  end

  describe "user is not logged in" do
    it "should not let the user create a comment" do
      expect {
        post comments_url, params: { comment: params }
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(302)
    end

    it "should not let the user update a comment" do
      user = create(:user)
      comment = create(:comment, entity: track, user: user)

      put comment_url(comment)
      expect(response).to have_http_status(302)
    end

    it "should not let the user delete a comment" do
      user = create(:user)
      comment = create(:comment, entity: track, user: user)

      expect {
        delete comment_url(comment)
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(302)
    end
  end
end
