class DownloadsController < ApplicationController
  def get_free_download
    @track = Track.kept.find(params[:id])

    if file_exists?(@track.tagged_mp3)
      send_data @track.tagged_mp3.download,
        filename: set_file_name(@track.tagged_mp3),
        type: "audio/mpeg",
        disposition: "attachment"
    else
      head :not_found
    end
  end

  def create_free_download
    @track = Track.kept.find(params[:id])

    free_download = FreeDownload.new(
      user: current_user,
      track: @track,
      **params.require(:free_download).permit(:email, :customer_name),
    )

    if file_exists?(@track.tagged_mp3)
      if free_download.save
        # TODO send email
        head :ok
      else
        head :unprocessable_content
      end
    else
      head :not_found
    end
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
    order_item = OrderItem.find(params[:id])

    if order_item.order.user != current_or_guest_user && !current_or_guest_user.admin?
      head :unauthorized and return
    end

    if order_item.order.status != Order.statuses[:completed] && !current_or_guest_user.admin?
      head :unauthorized and return
    end

    license = License.new(**order_item.license_snapshot)
    customer_full_name = order_item.order.payment_transaction.customer_name
    contract_markdown = if order_item.product_type == Track.name
      track = Track.new(**order_item.product_snapshot)
      Contracts::RenderTracksContractService.new(license:, track:, customer_full_name:).call
    else
      ""
    end

    construct_and_send_contract(markdown: contract_markdown, name: "#{order_item.product_name} #{license.title}")
  end

  def contract
    license = License.kept.find(params[:id])
    entity = if params[:entity] == Track.name
      Track.kept.find(params[:entity_id])
    else
      nil
    end

    contract_markdown = if params[:entity] == Track.name
      Contracts::RenderTracksContractService.new(license:, track: entity, customer_full_name: "DOWNLOADER").call
    else
      ""
    end

    construct_and_send_contract(markdown: contract_markdown, name: "Free Download - #{license.title}")
  end

  private

  def set_file_name(file)
    file.filename.to_s
  end

  def file_exists?(file)
    file.attached?
  end

  def construct_and_send_contract(markdown:, name:)
    markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    contract_html = markdown_renderer.render(markdown)
    pdf = Prawn::Document.new(page_size: "A4")
    PrawnHtml.append_html(pdf, contract_html)

    send_data pdf.render,
      filename: "#{name}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end
end
