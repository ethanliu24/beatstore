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

  has_many :interactions, class_name: "Comment::Interaction"

  class << self
    def valid_entity_types
      [ Track ].map { |cls| cls.name }
    end
  end

  private

  def valid_entity_types
    Comment.valid_entity_types
  end
end
