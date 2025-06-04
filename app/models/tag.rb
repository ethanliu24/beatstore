class Tag < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :value, uniqueness: { scope: :track_id }

  belongs_to :track
  accepts_nested_attributes_for :tags
end
