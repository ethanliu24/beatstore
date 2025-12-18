# Preview all emails at http://localhost:3000/rails/mailers

class FreeDownloadMailerPreview < ActionMailer::Preview
  def download
    track = Track.last || FactoryBot.create(:track_with_files)
    free_download = FreeDownload.last || FactoryBot.create(
      :free_download,
      track:,
      customer_name: "John",
      email: "email@example.com"
    )

    FreeDownloadMailer.with(free_download:).download
  end
end
