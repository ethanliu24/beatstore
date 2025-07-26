class Comment::Interaction < ApplicationRecord
  enum type: { like: "like", dislike: "dislike" }

  belongs_to :comment
end
