class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, except: [ :create ]
  before_action :user_can_manage?, except: [ :create ]

  def create
    entity_class = resolve_entity_class(params[:comment][:entity_type])
    if entity_class.nil?
      head :unprocessable_entity
      return
    end

    entity = entity_class.find(params[:comment][:entity_id])

    @comment = Comment.create!(
      content: params[:comment][:content],
      entity:,
      user: current_user
    )
  end

  def update
    @comment.update!(params.require(:comment).permit(:content))
  end

  def destroy
    @comment.destroy!
  end

  private

  def resolve_entity_class(entity_type)
    case entity_type
    when Track.name
      Track
    else
      nil
    end
  end

  def user_can_manage?
    unless current_user.admin? || current_user.id == @comment.user.id
      head :unauthorized
    end
  end

  def sanitize_comment_params
    params.require(:comment).permit(
      :content,
      :entity_type,
      :entity_id,
    )
  end

  def set_comment
    @comment = if current_user.admin?
      Comment.find(params[:id])
    else
      current_user.comments.find(params[:id])
    end
  end
end
