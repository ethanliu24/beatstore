# frozen_string_literal: true

class Api::TracksController < ApplicationController
  include ActiveStorage::SetCurrent

  # Track data for audio player
  def show
    track = Track.find_by(id: params[:id])

    if track && (current_user&.admin? || track.is_public?)
      render json: {
        id: track.id,
        title: track.title,
        bpm: track.bpm,
        key: track.key,
        liked_by_user: current_user ? current_user.hearted?(track) : false,
        cover_photo: track.cover_photo.attached? ? track.cover_photo.url(expires_in: 5.minutes) : "",
        tagged_mp3: track.tagged_mp3.attached? \
          ? track.tagged_mp3.url(expires_in: 5.minutes)
          : ""
      }
    else
      head :not_found
    end
  end
end
