# frozen_string_literal: true

require "open3"

module BackUps
  class DumpPgDatabaseService
    class Result
      attr_reader :path, :message, :error

      def initialize(success:, path: nil, message: nil, error: nil)
        @success = success
        @path = path
        @message = message
        @error = error
      end

      def ok?
        @success
      end

      def dir
        path.nil? ? nil : File.dirname(@path)
      end
    end

    # config is a db config, e.g. Rails.configuration.database_configuration[Rails.env]["primary"]
    def initialize(config)
      @database = config["database"]
      @username = config["username"]
      @password = config["password"]
      @host = config["host"]
      @backup_path = tmp_path
    end

    def perform
      stdout, stderr, status = Open3.capture3(command)
      result = Result.new(success: status.success?, path: @backup_path, message: stdout, error: stderr)

      Metric.track(Metrics::Name::BACKUP_PG_DUMP_RESULT, tags: {
        success: result.ok?, path: result.path
      })

      result
    end

    private

    def command
      "PGPASSWORD='#{@password}' pg_dump -h #{@host} -U #{@username} -Fc -d #{@database} -f #{@backup_path}"
    end

    def tmp_path
      time = Time.current.strftime("%Y-%m-%d-%H:%M:%S")
      filename = "#{time}.dump"
      path = Rails.root.join("tmp", "db_backups", @database, filename)
      FileUtils.mkdir_p(File.dirname(path))

      path.to_s
    end
  end
end
