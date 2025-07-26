class Comment::Interaction < ApplicationRecord
  self.table_name = "comment_interactions"

  enum :interaction_type, { like: "like", dislike: "dislike" }

  validates :interaction_type, presence: true

  belongs_to :comment, optional: false
  belongs_to :user, optional: true
end
