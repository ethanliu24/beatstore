# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"

module BackUps
  class UploadToCloudService
    def call(backup)
      unless backup.is_a?(BackUps::DumpDatabaseService::Result)
        raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
      end

      unless backup.ok?
        raise ArgumentError, "<backup> data dump is not successful, cannot upload"
      end

      drive_service = Google::Apis::DriveV3::DriveService.new

      credentials = Settings.google.backup.service_account.to_json
      scope = "https://www.googleapis.com/auth/drive"
      drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials),
        scope: scope
      )

      file_metadata = {
        name: backup.filename,
        parents: [ "PASTE_YOUR_SHARED_FOLDER_ID_HERE" ]
      }

      # 4. Upload the file
      file = drive_service.create_file(
        file_metadata,
        fields: "id",
        upload_source: backup.path, # Path to your local file
        content_type: "text/plain"       # Change this based on your file type
      )

      puts "File uploaded successfully! File ID: #{file.id}"
    end
  end
end
