class Comment::Interaction < ApplicationRecord
  self.table_name = "comment_interactions"

  enum :interaction_type, { like: "like", dislike: "dislike" }

  validates :interaction_type, presence: true
  validates :user_id, uniqueness: { scope: :comment_id }, if: -> { user_id.present? }

  belongs_to :comment, optional: false
  belongs_to :user, optional: true

  scope :likes, -> { where(interaction_type: "like") }
  scope :dislikes, -> { where(interaction_type: "dislike") }
end
