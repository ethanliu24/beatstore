class DownloadsController < ApplicationController
  def free_download
    @track = Track.find(params[:id])

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

  def product_item
    order = if current_or_guest_user.admin?
      Order.find(params[:id])
    else
      current_or_guest_user.orders.find(params[:id])
    end
    order_item = order.order_items.find(params[:item_id])
    file = order_item.files.find(params[:file_id])

    unless order.status == Order.statuses[:completed]
      redirect_back fallback_location: root_path
      return
    end

    send_data file.download,
      filename: set_file_name(file),
      type: file.blob.content_type,
      disposition: "attachment"
  end

  def order_item_contract
    
  end

  private

  def set_file_name(file)
    file.filename.to_s
  end

  def file_exists?(file)
    file.attached?
  end
end
