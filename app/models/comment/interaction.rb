class Comment::Interaction < ApplicationRecord
  self.table_name = "comment_interactions"

  enum type: { like: "like", dislike: "dislike" }

  validates :type, inclusion: { in: types }

  belongs_to :comment, optional: false
  belongs_to :user, optional: true
end
