# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"

module BackUps
  class UploadToCloudService
    FOLDER_IDS = {
      primay: Setting.backup.google_drive.folders.primary,
      queue: Setting.backup.google_drive.folders.queue,
      cable: Setting.backup.google_drive.folders.cable,
      cache: Setting.backup.google_drive.folders.cache,
      errors: Setting.backup.google_drive.folders.errors
    }.freeze

    def call(backup, db_key:)
      unless backup.is_a?(BackUps::DumpDatabaseService::Result)
        raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
      end

      unless backup.ok?
        raise ArgumentError, "<backup> data dump is not successful, cannot upload"
      end

      unless FOLDER_IDS.include?(db_key)
        raise ArgumentError, "<db_key> #{db_key} is not a valid or defined database key, check config/database.yml"
      end

      drive_service = Google::Apis::DriveV3::DriveService.new
      credentials = Settings.backup.google_drive.service_account.to_json
      drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials),
        scope: Settings.google_drive_api_url
      )

      file_metadata = {
        name: backup.filename,
        parents: [ FOLDER_IDS[db_key] ]
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
