class Comments::InteractionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  LIKE_INTERACTION = Comment::Interaction.interaction_types[:like]
  DISLIKE_INTERACTION = Comment::Interaction.interaction_types[:dislike]

  def like
    like = find_interaction(LIKE_INTERACTION)
    dislike = find_interaction(DISLIKE_INTERACTION)

    dislike.destroy! unless dislike.nil?
    create_interaction(LIKE_INTERACTION) if like.nil?

    update_comment_view
  end

  def unlike
    like = find_interaction("like")
    like&.destroy!

    update_comment_view
  end

  def dislike
    dislike = find_interaction(DISLIKE_INTERACTION)
    like = find_interaction(LIKE_INTERACTION)

    like.destroy! unless like.nil?
    create_interaction(DISLIKE_INTERACTION) if dislike.nil?

    update_comment_view
  end

  def undislike
    dislike = find_interaction(Comment::Interaction.interaction_types[:dislike])
    dislike&.destroy!

    update_comment_view
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def create_interaction(interaction_type)
    Comment::Interaction.create!(
      interaction_type:,
      comment_id: params[:id],
      user_id: current_user.id
    )
  end

  def find_interaction(interaction_type)
    current_user.comment_interactions.find_by(
      interaction_type:,
      comment_id: params[:id]
    )
  end

  def update_comment_view
    respond_to do |format|
      format.turbo_stream { render "comments/update" }
    end
  end
end
