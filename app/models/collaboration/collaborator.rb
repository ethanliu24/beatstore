# frozen_string_literal: true

module Collaboration
  class Collaborator < ApplicationRecord
    enum :role, {
      producer: "producer",
      songwriter: "songwriter",
      composer: "composer",
      arranger: "arranger",
      engineer: "engineer"
    }

    validates :name, presence: true
    validates :role, presence: true
    validates :notes, presence: true, allow_blank: true
    validates :profit_share,
      presence: true,
      numericality: { greater_than: 0, less_than_or_equal_to: 100 }
    validates :publishing_share,
      presence: true,
      numericality: { greater_than: 0, less_than_or_equal_to: 100 }

    belongs_to :track
  end
end
