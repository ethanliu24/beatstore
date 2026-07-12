# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"
require "stringio"

module BackUps
  class UploadToCloudService
    API_SCOPE = "https://www.googleapis.com/auth/drive.file"
    FOLDER_IDS = {
      primary: Settings.backup.google_drive.folders.primary,
      queue: Settings.backup.google_drive.folders.queue,
      cable: Settings.backup.google_drive.folders.cable,
      cache: Settings.backup.google_drive.folders.cache,
      errors: Settings.backup.google_drive.folders.errors
    }.freeze

    class << self
      def call(backup, db_key:)
        if backup.class.name != "BackUps::DumpDatabaseService::Result"
          raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
        end

        unless backup.ok?
          raise ArgumentError, "<backup> data dump is not successful, cannot upload"
        end

        unless FOLDER_IDS.keys.include?(db_key.to_sym)
          raise ArgumentError, "<db_key> #{db_key} is not a valid or defined database key, check config/database.yml"
        end

        drive_service = Google::Apis::DriveV3::DriveService.new
        credentials = Google::Auth::UserRefreshCredentials.new(
          client_id: GD_CLIENT_ID,
          client_secret: GD_CLIENT_SECRET,
          refresh_token: GG_REFRESH_TOKEN,
          scope: API_SCOPE
        )
        drive_service.authorization = credentials

        file_metadata = Google::Apis::DriveV3::File.new(
          name: FILE_PATH.split("/").last,
          parents: [ FOLDER ]
        )

        file = drive_service.create_file(
          file_metadata,
          fields: "id",
          upload_source: FILE_PATH,
          content_type: "application/octet-stream"
        )

        file
      end
    end
  end
end
