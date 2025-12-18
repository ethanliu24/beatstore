class FreeDownloadMailer < ApplicationMailer
  def download
    @free_download = params[:free_download]
    @track = @free_download.track
    @free_license = @track.licenses.kept.find { |l| l.price_cents == 0 }

    subject = "Your Download - #{@track.title}"

    recipients = [ @free_download.email ]
    mail(to: recipients, subject:)
  end
end
