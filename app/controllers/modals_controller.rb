class ModalsController < ApplicationController
  before_action :ensure_turbo_request

  def auth_prompt
    render_modal(partial: "modals/auth_prompt")
  end

  def track_image_upload
    render_modal(partial: "modals/image_upload", locals: {
      **image_upload_data(
        model_field: "track[cover_photo]",
        img_destination_id: "track-cover-photo-preview",
        file_upload_input_container_id: "cover-photo-upload-container"
      )
    })
  end

  def user_pfp_upload
    render_modal(partial: "modals/image_upload", locals: {
      **image_upload_data(
        model_field: "user[profile_picture]",
        img_destination_id: "user-pfp-preview",
        file_upload_input_container_id: "pfp-upload-container"
      )
    })
  end

  def delete_account
    render_modal(partial: "modals/delete_account")
  end

  def delete_comment
    comment = Comment.find(params[:id])
    render_modal(partial: "modals/delete_comment", locals: { comment: })
  end

  def track_more_info
    track = Track.find(params[:id])
    render_modal(partial: "modals/track_more_info", locals: { track: })
  end

  # If license doesn't exist in DB, render default template, which requires contract_type in params.
  # Else will decide which service to call to render the contract, which is specified by entity_type in params.
  # It should be the class name of the entity that's associated with the license.
  def preview_contract
    license = License.find_by(id: params[:license_id])
    entity_type = params[:entity_type]

    content = if license.nil?
      Rails.configuration.templates[:contracts][params[:contract_type]]
    elsif entity_type = Track.name
      track = Track.find_by(id: params[:track_id])
      Contracts::RenderTracksContractService.new(license:, track:).call
    else
      ""
    end

    render_modal(partial: "modals/preview_contract", locals: { content: })
  end

  def track_purchase
    track = Track.find(params[:id])
    render_modal(partial: "modals/track_purchase", locals: { track:, partial_id: "license-tabs-track-purchase-modal" })
  end

  private

  def render_modal(partial:, locals: {})
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("modal", partial:, locals:,) }
    end
  end

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
