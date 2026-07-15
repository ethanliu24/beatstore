# frozen_string_literal: true

module BackUps
  class CleanUpBackupArtifactsService
    class << self
      def call(backup)
        if backup.class.name != "BackUps::DumpDatabaseService::Result"
          raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
        end

        unless backup.ok?
          raise ArgumentError, "<backup> data dump is not successful"
        end

        unless File.exist?(backup.path)
          raise Errno::ENOENT, backup.path
        end

        File.delete(backup.path)

        Metric.track(Metrics::Name::CLEAN_UP_BACKUP_ARTIFACT_RESULT, tags: { status: :success })
      rescue => e
        Metric.track(Metrics::Name::CLEAN_UP_BACKUP_ARTIFACT_RESULT, tags: { status: :fail })
        raise e
      end
    end
  end
end
