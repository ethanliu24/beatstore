# frozen_string_literal: true

module Contracts
  module Track
    class NonExclusive < Contracts::Track::Base
      attribute :distribution_copies, :integer
      attribute :streams_allowed, :integer
      attribute :non_monetized_videos, :integer
      attribute :monetized_videos, :integer
      attribute :non_monetized_video_streams, :integer
      attribute :monetized_video_streams, :integer
      attribute :non_profitable_performances, :integer
      attribute :has_broadcasting_rights, :boolean
      attribute :radio_stations_allowed, :integer
      attribute :allow_profitable_performances, :boolean
      attribute :non_profitable_performances_allowed, :integer

      validates :distribution_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :streams_allowed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :radio_stations_allowed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :has_broadcasting_rights, presence: true
      validates :allow_profitable_performances_allowed, presence: true

      private

      # TODO validate unlimitable integer fields
    end
  end
end
