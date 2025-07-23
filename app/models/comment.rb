# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_COMMENT_LENGTH = 200

  validates :content, presence: true, length: { maximum: Comment::MAX_COMMENT_LENGTH }

  belongs_to :entity, polymorphic: true
  belongs_to :user, optional: false
end
