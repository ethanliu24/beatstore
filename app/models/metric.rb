# frozen_string_literal: true

class Metric < ApplicationRecord
  DEFAULT_PRUNES_AFTER = 3.months

  validates :event_name, presence: true
  validates :created_at, presence: true
  validate :event_name_is_defined
  validate :tags_is_hash

  class << self
    def track(event_name, tags: {}, prune: true, prunes_after: DEFAULT_PRUNES_AFTER)
      created_at = Time.current
      prunes_at = prune ? created_at + prunes_after : nil

      Metric.create!(event_name:, tags:, prunes_at:, created_at:)
    end
  end

  private

  def event_name_is_defined
    unless Metrics::Name.is_defined?(event_name)
      errors.add(:event_name, "is not defined - add in Metric::Names")
    end
  end

  def tags_is_hash
    unless tags.kind_of?(Hash)
      errors.add(:tags, "must be a hash")
    end
  end
end
