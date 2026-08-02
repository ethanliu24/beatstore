# frozen_string_literal: true

module BackUps
  class PerformSnapshotBackupService
    class SnapshotBackupFailed < StandardError; end

    class << self
      def call(db_key, upload_to_cloud_service)
        env_config = Rails.configuration.database_configuration[Rails.env]
        config = env_config[db_key] || env_config

        return if config.blank?

        unless upload_to_cloud_service.respond_to?(:call)
          raise ArgumentError, "<upload_to_cloud_service> must respond to #call"
        end

        begin
          backup = DumpDatabaseService.new(config).perform

          unless backup.ok?
            raise SnapshotBackupFailed, "backup file dump result not ok"
          end

          Rails.error.handle do
            upload_to_cloud_service.call(backup, db_key:)
          end

          Metric.track(Metrics::Name::PERFORM_SNAPSHOT_BACKUP_RESULT, tags: {
            status: :success,
            db_key:
          })
        ensure
          CleanUpBackupArtifactsService.call(backup)
        end
      rescue SnapshotBackupFailed => e
        Metric.track(Metrics::Name::PERFORM_SNAPSHOT_BACKUP_RESULT, tags: {
          status: :fail,
          db_key:
        })

        raise e
      end
    end
  end
end
