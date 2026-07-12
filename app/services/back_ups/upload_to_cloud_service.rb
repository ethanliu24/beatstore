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

    def initialize
      @google_drive = Google::Apis::DriveV3::DriveService.new
      configure_cloud
    end

    def call(backup, db_key:)
      db_key = db_key.to_sym

      if backup.class.name != "BackUps::DumpDatabaseService::Result"
        raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
      end

      unless backup.ok?
        raise ArgumentError, "<backup> data dump is not successful, cannot upload"
      end

      unless FOLDER_IDS.keys.include?(db_key)
        raise ArgumentError, "<db_key> #{db_key} is not a valid or defined database key, check config/database.yml"
      end

      file_metadata = Google::Apis::DriveV3::File.new(
        name: backup.filename,
        parents: [ FOLDER_IDS[db_key] ]
      )

      file = @google_drive.create_file(
        file_metadata,
        fields: "id, name, size, parents, webViewLink, md5Checksum",
        upload_source: backup.path,
        content_type: backup.content_type
      )

      Metric.track(Metrics::Name::BACKUP_GOOGLE_DRIVE_UPLOAD_RESULT, tags: {
        status: :success,
        file_id: file.id,
        file_name: file.name,
        file_size: file.size,
        file_parents: file.parents,
        file_web_view_link: file.web_view_link,
        file_md5_checksum: file.md5_checksum
      })

      file
    rescue => e
      Metric.track(Metrics::Name::BACKUP_GOOGLE_DRIVE_UPLOAD_RESULT, tags: { status: :fail })
      raise e
    end

    private

    def configure_cloud
      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: Settings.google.api.oauth.client_id,
        client_secret: Settings.google.api.oauth.client_secret,
        refresh_token: Settings.google.api.oauth.google_drive_refresh_token,
        scope: API_SCOPE
      )

      @google_drive.authorization = credentials
    end
  end
end
