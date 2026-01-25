# frozen_string_literal: true

class Api::TracksController < ApplicationController
  # Track data for audio player
  def show
    track = Track.kept.find(params[:id])

    if track.preview.attached? && (current_user&.admin? || track.available?)
      render json: {
        id: track.id,
        title: track.title,
        bpm: track.bpm,
        key: track.key,
        liked_by_user: current_user ? current_user.hearted?(track) : false,
        cover_photo_url: track.cover_photo.attached? ? track.cover_photo.url(expires_in: 5.minutes) : "",
        preview_url: track.preview.url(expires_in: 5.minutes),
        cheapest_price: track.cheapest_price
      }
    else
      head :not_found
    end
  end
end
