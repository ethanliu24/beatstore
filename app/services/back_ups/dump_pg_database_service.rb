# frozen_string_literal: true

require "open3"

module BackUps
  class DumpPgDatabaseService
    class Result
      attr_reader :backup_path, :error, :out

      def initialize(success:, backup_path: nil, error: nil, out: nil)
        @success = success
        @backup_path = backup_path
        @error = error
        @stdout = out
      end

      def ok?
        @success
      end
    end

    # config is a db config, e.g. Rails.configuration.database_configuration[Rails.env]["primary"]
    def initialize(config)
      @database = @config["database"]
      @username = @config["username"]
      @password = @config["password"]
      @host = @config["host"]
      @backup_path = tmp_path
    end

    def perform
      stdout, stderr, status = Open3.capture3(command)
      Result.new(success: status.success?, backup_path: @backup_path, error: stderr, out: stdout)
    end

    private

    def command
      "PGPASSWORD='#{@password}' pg_dump -h #{@host} -U #{@username} -Fc -d #{@db_name} -f #{@backup_path}"
    end

    def tmp_path
      filename = "#{@database}_#{Time.current.strftime("%Y-%m-%d-%H:%M:%S")}.dump"
      Rails.root.join("tmp", "db_backups", filename)
    end
  end
end
