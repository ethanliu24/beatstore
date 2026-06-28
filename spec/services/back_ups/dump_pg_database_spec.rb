# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::DumpPgDatabaseService do
  let(:backup_time) { Time.zone.parse("2026-01-01 11:11:11") }
  let(:config) {
    {
      "database" => "my_db",
      "username" => "user",
      "password" => "secret",
      "host"     => "localhost"
    }
  }

  describe "#perform" do
    let(:expected_command) {
      /PGPASSWORD='secret' pg_dump -h localhost -U user -Fc -d my_db -f .+\.dump/
    }

    before do
      travel_to backup_time
    end

    it "executes the correct pg_dump command" do
      expect(Open3).to receive(:capture3)
        .with(expected_command)
        .and_return([ "", "", double(success?: true) ])

      result = service.perform
      expect(result.ok?).to eq(true)
      expect(result.backup_path).to include("tmp/db_backups/my_db/2026-01-01-11:11:11")
    end

    it "returns an error if the command fails" do
      # Mock a failure
      allow(Open3).to receive(:capture3).and_return([ "", "Access Denied", double(success?: false) ])

      result = service.perform
      expect(result.ok?).to eq(false)
      expect(result.error).to eq("Access Denied")
    end
  end

  private

  def service
    described_class.new(config)
  end
end
