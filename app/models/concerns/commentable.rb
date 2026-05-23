# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :entity, dependent: :destroy
  end

  def num_comments
    comments.kept.count
  end
end
