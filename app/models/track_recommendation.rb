# frozen_string_literal: true

class TrackRecommendation < ApplicationRecord
  before_validation { self.disabled = false if disabled.nil? }

  MAX_GROUP_LENGTH = 25

  validates :group, presence: true, uniqueness: true, length: { maximum: MAX_GROUP_LENGTH }
  validates :display_image, content_type: [ "image/png" ], if: -> { display_image.attached? }
  validates :tag_names, presence: true
  validate :tag_names_is_array

  has_one_attached :display_image

  private

  def tag_names_is_array
    if tag_names.nil?
      errors.add(:tag_name, "is required")
      return
    end

    unless tag_names.kind_of?(Array)
      errors.add(:tag_name, "must be an array")
      return
    end

    unless tag_names.all? { |name| name.is_a?(String) }
      errors.add(:tag_name, "must contain an array of strings")
    end
  end
end
