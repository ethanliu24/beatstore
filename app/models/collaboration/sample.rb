# frozen_string_literal: true

module Collaboration
  class Sample < ApplicationRecord
    validates :name, presence: true

    belongs_to :track, optional: false

    after_initialize :set_defaults, if: :new_record?

    private

    def set_defaults
      self.name ||= ""
    end
  end
end
