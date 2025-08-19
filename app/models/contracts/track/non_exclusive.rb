# frozen_string_literal: true

module Contracts
  module Track
    class NonExclusive < Contracts::Track::Base
      attribute :distribution_copies
      attribute :non_monetized_videos
      attribute :monetized_videos
      attribute :non_monetized_video_streams
      attribute :monetized_video_streams
      attribute :non_profitable_performances
      attribute :has_broadcasting_rights
      attribute :radio_stations_allowed
      attribute :allow_profitable_performances

      validates :distribution_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :non_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :has_broadcasting_rights, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :radio_stations_allowed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :allow_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    end
  end
end
