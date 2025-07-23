# frozen_string_literal: true

class Comment < ApplicationRecord
  MAX_COMMENT_LENGTH = 200

  belongs_to :entity, polymorphic: true
  belongs_to :user

  validates :content, presence: true, length: { maximum: MAX_COMMENT_LENGTH }
end
