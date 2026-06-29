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
        parents: []
      }

      file = drive_service.create_file(
        file_metadata,
        fields: "id",
        upload_source: backup.path,
        content_type: "application/octet-stream"
      )

      file
    end
  end
end
