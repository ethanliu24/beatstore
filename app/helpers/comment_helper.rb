# frozen_string_literal: true

module CommentHelper
  def comment_more_dropdown_id(comment)
    "comment-#{comment.id}-more-dropdown"
  end
end
