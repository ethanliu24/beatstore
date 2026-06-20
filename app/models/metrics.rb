# frozen_string_literal: true

class Metrics < ApplicationRecord
  validates :event_name, presence: true
  validates :tags, presence: true
  validates :prunes_at, presence: true
  validates :created_at, presence: true

  class << self
    def track(event_name, tags: {}, prune: true, prunes_after: PruneTime::DEFAULT)
      prunes_at = prune ? prunes_after : nil
      created_at = Time.current

      Metrics.create!(event_name:, tags:, prunes_at:, created_at:)
    end
  end
end
