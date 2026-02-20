# frozen_string_literal: true

class TrackRecommendation < ApplicationRecord
  before_validation { self.disabled = false if disabled.nil? }

  MAX_GROUP_LENGTH = 25

  validates :group, presence: true, uniqueness: true, length: { maximum: MAX_GROUP_LENGTH }
  validates :display_image, content_type: [ "image/png" ], if: -> { display_image.attached? }
  validate :tag_name_is_array

  has_one_attached :display_image

  private

  def tag_name_is_array
    unless tag_name.kind_of?(Array)
      errors.add(:tag_name, "must be an array")
      return
    end

    unless tag_name.all? { |name| name.is_a?(String) }
      errors.add(:tag_name, "must contain an array of strings")
    end
  end
end
