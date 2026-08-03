# frozen_string_literal: true

module BackUps
  class PerformSnapshotBackupService
    class SnapshotBackupFailed < StandardError; end

    class << self
      def call(db_key)
        env_config = Rails.configuration.database_configuration[Rails.env]
        config = env_config[db_key] || env_config

        return if config.blank?

        begin
          backup = DumpDatabaseService.new(config).perform

          unless backup.ok?
            raise SnapshotBackupFailed, "backup file dump result not ok"
          end

          Rails.error.handle do
            BackUps::UploadToCloudService.instance.call(backup, db_key:)
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
