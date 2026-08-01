# frozen_string_literal: true

module BackUps
  class PerformSnapshotBackupService
    class SnapshotBackupFailed < StandardError; end

    class << self
      def call(db_key, upload_to_cloud_service)
        config = Rails.configuration.database_configuration[Rails.env][db_key] || \
          Rails.configuration.database_configuration[Rails.env]

        return unless config

        unless upload_to_cloud_service.respond_to?(:call)
          raise ArgumentError, "<upload_to_cloud_service> must respond to #call"
        end

        backup = DumpDatabaseService.new(config).perform

        unless backup.ok?
          CleanUpBackupArtifactsService.call(backup)
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
end
