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
      attribute :has_broadcasting_rights, :boolean
      attribute :radio_stations_allowed, :integer
      attribute :allow_profitable_performances, :boolean
      attribute :non_profitable_performances, :integer

      validates :distribution_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { distribution_copies.present? }
      validates :streams_allowed, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { streams_allowed.present? }
      validates :non_monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { non_monetized_videos.present? }
      validates :monetized_videos, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { monetized_videos.present? }
      validates :non_monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { non_monetized_video_streams.present? }
      validates :monetized_video_streams, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { monetized_video_streams.present? }
      validates :non_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { non_profitable_performances.present? }
      validates :radio_stations_allowed, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { radio_stations_allowed.present? }
      validates :non_profitable_performances, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
        if: -> { non_profitable_performances.present? }
      validates :has_broadcasting_rights, inclusion: { in: [ true, false ] }
      validates :allow_profitable_performances, inclusion: { in: [ true, false ] }

      private

      # TODO validate unlimitable integer fields
    end
  end
end
