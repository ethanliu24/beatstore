class ModalsController < ApplicationController
  include ExtractSlugToTrackId

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
    comment = Comment.kept.find(params[:id])
    render_modal(partial: "modals/delete_comment", locals: { comment: })
  end

  def track_more_info
    id = extract_track_id(params.expect(:id))
    track = Track.kept.find(id)
    render_modal(partial: "modals/track_more_info", locals: { track: })
  end

  # There are two cases, either in params license_id is passed (with other neccessary params) or order_item_id.
  # This is so that we render the right thing on different situation. Definitely a cleaner way to do this,
  # but I cannot give a fuck at the moment.
  def preview_contract
    content = if params[:license_id].present?
      license = License.kept.find_by(id: params[:license_id])
      entity_type = params[:entity_type]

      # If license doesn't exist in DB, render default template, which requires contract_type in params.
      # Else will decide which service to call to render the contract, which is specified by entity_type in params.
      # It should be the class name of the entity that's associated with the license.
      if license.nil?
        Rails.configuration.templates[:contracts][params[:contract_type]]
      elsif entity_type = Track.name
        track = Track.kept.find_by(id: params[:track_id])
        Contracts::RenderTracksContractService.new(license:, track:).call
      else
        ""
      end
    elsif params[:order_item_id].present?
      order_item = OrderItem.find(params[:order_item_id])
      customer_full_name = order_item.order.payment_transaction.customer_name

      if order_item.order.user != current_or_guest_user && !current_or_guest_user.admin?
        head :not_found and return
      end

      case order_item.product_type
      when Track.name
        track = Track.new(**order_item.product_snapshot)
        license = License.new(**order_item.license_snapshot)
        Contracts::RenderTracksContractService.new(license:, track:, customer_full_name:).call
      else
        ""
      end
    else
      ""
    end

    render_modal(partial: "modals/preview_contract", locals: { content:, order_item_id: params[:order_item_id] })
  end

  def track_purchase
    track_id = extract_track_id(params.expect(:id))
    track = Track.kept.find(track_id)
    initial_license_id = params[:initial_id].presence || track.profitable_licenses.first&.id
    render_modal(partial: "modals/track_purchase", locals: { track:, initial_license_id: })
  end

  def free_download
    id = extract_track_id(params.expect(:id))
    track = Track.kept.find(id)
    free_download = FreeDownload.new
    render_modal(partial: "modals/free_download", locals: { track:, free_download: })
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
