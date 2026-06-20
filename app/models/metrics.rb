# frozen_string_literal: true

class Metrics < ApplicationRecord
  validates :event_name, presence: true
  validates :prunes_at, presence: true
  validates :created_at, presence: true
  validate :event_name_is_defined
  validate :tags_is_hash

  class << self
    def track(event_name, tags: {}, prune: true, prunes_after: PruneTime::DEFAULT)
      prunes_at = prune ? prunes_after : nil
      created_at = Time.current

      Metrics.create!(event_name:, tags:, prunes_at:, created_at:)
    end
  end

  def event_name_is_defined
    unless Names.is_defined?(self.event_name)
      errors.add(:event_name, "is not defined - add in Metrics::Names")
    end
  end

  def tags_is_hash
    unless tag_names.kind_of?(Hash)
      errors.add(:tags, "must be a hash")
    end
  end
end
