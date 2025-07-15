class ModalsController < ApplicationController
  before_action :ensure_turbo_request

  def auth_prompt
    render partial: "modals/auth_prompt"
  end

  def track_image_upload
    render partial: "modals/image_upload", locals: {
      **image_upload_data(
        model_field: "track[cover_photo]",
        img_destination_id: "track-cover-photo-preview",
        file_upload_input_container_id: "cover-photo-upload-container"
      )
    }
  end

  def user_pfp_upload
    render partial: "modals/image_upload", locals: {
      **image_upload_data(
        model_field: "user[profile_picture]",
        img_destination_id: "user-pfp-preview",
        file_upload_input_container_id: "pfp-upload-container"
      )
    }
  end

  def delete_account
    render partial: "modals/delete_account"
  end

  private

  def ensure_turbo_request
    # For Turbo Frames or Turbo Streams, request is xhr? or format.turbo_stream
    unless turbo_or_xhr_request?
      redirect_back(fallback_location: root_path)
    end
  end

  def image_upload_data(model_field:, img_destination_id:, file_upload_input_container_id:)
    {
      model_field:,
      img_destination_id:,
      file_upload_input_container_id:
    }
  end
end
