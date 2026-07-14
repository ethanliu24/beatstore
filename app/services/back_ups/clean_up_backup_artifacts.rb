# frozen_string_literal: true

module BackUps
  class CleanUpBackupArtifacts
    class << self
      def call(backup)
        if backup.class.name != "BackUps::DumpDatabaseService::Result"
          raise ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got #{backup.class.name}"
        end

        unless backup.ok?
          raise ArgumentError, "<backup> data dump is not successful, cannot upload"
        end

        unless File.exist?(backup.path)
          raise Errno::ENOENT, "<backup> file path does not exist: #{backup.path}"
        end

        File.delete(backup.path)
      end
    end
  end
end
