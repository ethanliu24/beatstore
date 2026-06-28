# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::DumpPgDatabaseService do
  let(:backup_time) { Time.zone.parse("2026-01-01 11:11:11") }
  let(:db_config) { Rails.configuration.database_configuration[Rails.env] }

  describe "#perform" do
    let(:expected_command) {
      /PGPASSWORD='beatstore' pg_dump -h 127.0.0.1 -U beatstore -Fc -d beatstore_test -f .+\.dump/
    }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      travel_to backup_time
    end

    it "executes the correct pg_dump command" do
      expect(Open3).to receive(:capture3)
        .with(expected_command)
        .and_return([ "", "", double(success?: true) ])

      result = service.perform
      expect(result.ok?).to eq(true)
      expect(result.backup_path).to include("tmp/db_backups/beatstore_test/2026-01-01-11:11:11.dump")
    end

    it "returns an error if the command fails" do
      # Mock a failure
      allow(Open3).to receive(:capture3).and_return([ "", "Access Denied", double(success?: false) ])

      result = service.perform
      expect(result.ok?).to eq(false)
      expect(result.error).to eq("Access Denied")
    end
  end

  context "integration" do
    it 'actually creates a file', :integration do
      result = service.perform
      expect(File.exist?(result.backup_path)).to eq(true)

      FileUtils.rm_rf(result.dir)
    end
  end

  private

  def service
    described_class.new(db_config)
  end
end
