class Comments::InteractionsController < ApplicationController
  before_action :authenticate_user!

  LIKE_INTERACTION = Comment::Interaction.interaction_types[:like]
  DISLIKE_INTERACTION = Comment::Interaction.interaction_types[:dislike]

  # TODO add toast for each of the following actions

  def like
    like = find_interaction(LIKE_INTERACTION)
    dislike = find_interaction(DISLIKE_INTERACTION)

    dislike.destroy! unless dislike.nil?
    create_interaction(LIKE_INTERACTION) if like.nil?
    head :no_content
  end

  def dislike
    dislike = find_interaction(DISLIKE_INTERACTION)
    like = find_interaction(LIKE_INTERACTION)

    like.destroy! unless like.nil?
    create_interaction(DISLIKE_INTERACTION) if dislike.nil?
    head :no_content
  end

  def unlike
    like = find_interaction("like")

    like&.destroy!
    head :no_content
  end

  def undislike
    dislike = find_interaction(Comment::Interaction.interaction_types[:dislike])

    dislike&.destroy!
    head :no_content
  end

  private

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
end
