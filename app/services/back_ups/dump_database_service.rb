# frozen_string_literal: true

require "open3"

module BackUps
  class DumpDatabaseService
    DUMP_FILE_CONTENT_TYPE = "application/octet-stream"

    class Result
      attr_reader :filename, :content_type, :path, :message, :error

      def initialize(success:, filename: nil, content_type: nil, path: nil, message: nil, error: nil)
        @success = success
        @filename = filename
        @content_type = content_type
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
      @backup_path, @filename = tmp_path
    end

    def perform
      stdout, stderr, status = Open3.capture3(command)
      result = if status.success?
        Result.new(
          success: true,
          filename: @filename,
          content_type: DUMP_FILE_CONTENT_TYPE,
          path: @backup_path,
          message: stdout,
          error: stderr
        )
      else
        Result.new(success: false, message: stdout, error: stderr)
      end

      Metric.track(Metrics::Name::BACKUP_PG_DUMP_RESULT, tags: {
        success: result.ok?, path: @backup_path, result_path: result.path
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

      [ path.to_s, filename ]
    end
  end
end
