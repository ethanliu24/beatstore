class ModalsController < ApplicationController
  before_action :ensure_turbo_request

  def test
    @track = Track.first
    render partial: "modals/test", locals: { track: @track }
  end

  def track_image_upload
    render partial: "modals/image_upload", locals: {
      **image_upload_data(
        model: "track",
        img_source_input_id: "dropzone-file",
        img_destination_id: "track-cover-photo-preview",
        file_upload_input_container_id: "cover-photo-upload-container"
      )
    }
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

  def image_upload_data(model:, img_source_input_id:, img_destination_id:, file_upload_input_container_id:)
    {
      "data-upload-model-value": model,
      "data-upload-img-source-input-id-value": img_source_input_id,
      "data-upload-img-destination-id-value": img_destination_id,
      "data-upload-file-upload-input-container-id-value": file_upload_input_container_id
    }
  end
end
