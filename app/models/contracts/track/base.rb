# frozen_string_literal: true

module Contracts
  module Track
    class Base < Contracts::Base
      attribute :terms_of_years, :integer
      attribute :delivers_mp3, :boolean
      attribute :delivers_wav, :boolean
      attribute :delivers_stems, :boolean

      validates :terms_of_years, numericality: { only_integer: true, greater_than: 0 }
    end
  end
end
