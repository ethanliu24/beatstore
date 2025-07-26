# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_COMMENT_LENGTH = 200

  validates :content, presence: true, length: { maximum: Comment::MAX_COMMENT_LENGTH }
  validates :entity_type, inclusion: {
    in: :valid_entity_types,
    message: "%{value} is not a valid entity type"
  }

  belongs_to :entity, polymorphic: true
  belongs_to :user, optional: false

  has_many :interactions, class_name: "Comment::Interaction", dependent: :destroy

  class << self
    def valid_entity_types
      [ Track ].map { |cls| cls.name }
    end
  end

  def likes
    interactions.likes
  end

  def dislikes
    interactions.dislikes
  end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  def disliked_by?(user)
    dislikes.exists?(user_id: user.id)
  end

  private

  def valid_entity_types
    Comment.valid_entity_types
  end
end
