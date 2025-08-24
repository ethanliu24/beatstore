# frozen_string_literal: true

module Contracts
  module Track
    class Base < Contracts::Base
      attribute :terms_of_years
      attribute :delivers_mp3
      attribute :delivers_wav
      attribute :delivers_stems

      validates :terms_of_years, numericality: { only_integer: true, greater_than: 0 }
    end
  end
end
