class ModalsController < ApplicationController
  before_action :ensure_turbo_request

  def test
    @track = Track.first
    render partial: "modals/test", locals: { track: @track }
  end

  def image_upload
    render partial: "modals/image_upload"
  end

  def crop_image
    render partial: "modals/crop_image"
  end

  private

  def ensure_turbo_request
    # For Turbo Frames or Turbo Streams, request is xhr? or format.turbo_stream
    unless turbo_frame_request? || request.xhr? || request.format.turbo_stream?
      redirect_back(fallback_location: root_path)
    end
  end
end
