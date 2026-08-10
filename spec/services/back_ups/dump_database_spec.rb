# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::DumpDatabaseService do
  let(:backup_time) { Time.zone.parse("2026-01-01 11:11:11") }
  let(:backup_filename) { "2026-01-01-11:11:11_beatstore_test.dump" }
  let(:backup_path) { "tmp/db_backups/beatstore_test/#{backup_filename}" }
  let(:db_config) { Rails.configuration.database_configuration[Rails.env] }

  before do
    FileUtils.rm_rf(Rails.root.join("tmp", "db_backups", "beatstore_test"))
  end

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

      expect {
        result = service.perform

        expect(result.ok?).to eq(true)
        expect(result.filename).to eq(backup_filename)
        expect(result.content_type).to be("application/octet-stream")
        expect(result.path).to include(backup_path)
        expect(result.message).to eq("")
        expect(result.error).to eq("")
      }.to change(Metric, :count).by(1)

      metric = Metric.last
      expect(metric.name).to eq(Metrics::Name::BACKUP_PG_DUMP_RESULT)
      expect(metric.tags["success"]).to eq(true)
      expect(metric.tags["path"]).to include(backup_path)
      expect(metric.tags["result_path"]).to include(backup_path)
    end

    it "returns an error if the command fails" do
      # Mock a failure
      allow(Open3).to receive(:capture3).and_return(
        [ "You don't have access", "Access Denied", double(success?: false) ]
      )

      expect {
        result = service.perform
        expect(result.ok?).to eq(false)
        expect(result.filename).to be(nil)
        expect(result.content_type).to be(nil)
        expect(result.path).to be(nil)
        expect(result.message).to be("You don't have access")
        expect(result.error).to eq("Access Denied")
      }.to change(Metric, :count).by(1)

      metric = Metric.last
      expect(metric.name).to eq(Metrics::Name::BACKUP_PG_DUMP_RESULT)
      expect(metric.tags["success"]).to eq(false)
      expect(metric.tags["path"]).to include(backup_path)
      expect(metric.tags["result_path"]).to be(nil)
    end
  end

  context "integration" do
    it "actually creates a file", :integration do
      skip "skip for ci for now, TODO figure out a way to test in ci"

      result = service.perform
      expect(File.exist?(result.path)).to eq(true)

      FileUtils.rm_rf(result.dir)
    end
  end

  private

  def service
    described_class.new(db_config)
  end
end
