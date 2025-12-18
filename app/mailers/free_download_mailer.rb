class FreeDownloadMailer < ApplicationMailer
  def download
    @free_download = params[:free_download]
    @track = @free_download.track

    subject = "Your Free Download - #{track.title}"

    recipients = [ @free_download.email ]
    mail(to: recipients, subject:)
  end
end
