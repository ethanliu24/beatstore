# frozen_string_literal: true

module Collaboration
  class Sample < ApplicationRecord
    validates :name, presence: true

    belongs_to :track, optional: false
  end
end
