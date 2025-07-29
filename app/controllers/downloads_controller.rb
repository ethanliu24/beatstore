class DownloadsController < ApplicationController
  before_action :set_track

  def free_download
    unless file_exists?(@track.tagged_mp3)
      # TODO should log error if track not exist
      redirect_back fallback_location: root_path
      return
    end

    send_data @track.tagged_mp3.download,
      filename: set_file_name(@track.tagged_mp3),
      type: "audio/mpeg",
      disposition: "attachment"
  end

  private

  def set_file_name(file)
    file.filename.to_s
  end

  def file_exists?(file)
    file.attached?
  end

  def set_track
    @track = Track.find(params[:id])
  end
end
