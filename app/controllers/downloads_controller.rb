class DownloadsController < ApplicationController
  before_action :set_track

  def free_download
    unless file_exists?(@track.tagged_mp3)
      # TODO should log error if track not exist
      redirect_back fallback_location: root_path
      return
    end

    send_data @track.tagged_mp3.download,
      filename: set_file_name(@track, "mp3"),
      type: :mp3,
      disposition: "attachment"
  end

  private

  def set_file_name(track, extension)
    "#{track.title} - #{track.bpm}bpm #{track.key.downcase}.#{extension}"
  end

  def file_exists?(file)
    file.attached?
  end

  def set_track
    @track = Track.find(params[:id])
  end
end
