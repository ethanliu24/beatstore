# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :entity, dependent: :destroy
  end

  def undiscarded_comments
    comments.kept
  end

  def num_comments
    undiscarded_comments.count
  end
end
