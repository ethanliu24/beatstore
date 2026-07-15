# frozen_string_literal: true

class BackUps
  class PerformSnapshotBackupService
    class SnapshotBackupFailed < StandardError; end

    def call(db_key, upload_to_cloud_service)
      config = Rails.configuration.database_configuration[Rails.env][db_key]

      unless config
        raise ArgumentError, "<db_key>: #{db_key} is not valid"
      end

      unless upload_to_cloud_service.class.name == "BackUps::UploadToCloudService"
        raise ArgumentError,
          "expected <upload_to_cloud_service> to be BackUps::UploadToCloudService, " \
          "got #{upload_to_cloud_service.class.name}"
      end

      backup = DumpDatabaseService.new(config).perform

      unless backup.ok?
        raise SnapshotBackupFailed, "backup file dump result not ok"
      end

      Rails.error.handle do
        upload_to_cloud_service.call(backup, db_key:)
      end

      CleanUpBackupArtifactsService.call(backup)
    rescue SnapshotBackupFailed => e
      raise e
    end
  end
end
