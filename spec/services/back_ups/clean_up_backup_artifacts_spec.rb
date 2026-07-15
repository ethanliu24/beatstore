# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::CleanUpBackupArtifactsService do
  let(:backup_path) { "path/to/backup.dump" }
  let(:mock_backup) {
    BackUps::DumpDatabaseService::Result.new(
      success: true,
      filename: "backup.dump",
      content_type: "application/octet-stream",
      path: backup_path,
      message: "",
      error: ""
    )
  }

  before do
    allow(File).to receive(:exist?).and_return(true)
  end

  it "should remove the file created with a success metric" do
    expect(File).to receive(:delete).with(backup_path)

    expect { call_service }.to change(Metric, :count).by(1)

    metric = Metric.last
    expect(metric.name).to eq(Metrics::Name::CLEAN_UP_BACKUP_ARTIFACT_RESULT)
    expect(metric.tags["status"]).to eq("success")
  end

  it "should raise an ArgumentError if backup is not BackUps::DumpDatabaseService::Result" do
    expect {
      call_service(backup: "backup")
    }.to raise_error(ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got String")
  end

  it "should raise an ArgumentError if backup is not successful" do
    allow(mock_backup).to receive(:ok?).and_return(false)

    expect {
      call_service
    }.to raise_error(ArgumentError, "<backup> data dump is not successful")
  end

  it "should raise an Errno::ENOENT if back up path doesn't exist" do
    allow(File).to receive(:exist?).and_return(false)

    expect {
      call_service
    }.to raise_error(Errno::ENOENT, "No such file or directory - #{backup_path}")
  end

  it "shuold emit a failed status metric on any error" do
    allow(File).to receive(:delete).and_raise(StandardError)

    expect {
      expect {
        call_service
      }.to change(Metric, :count).by(1)
    }.to raise_error(StandardError)

    metric = Metric.last
    expect(metric.name).to eq(Metrics::Name::CLEAN_UP_BACKUP_ARTIFACT_RESULT)
    expect(metric.tags["status"]).to eq("fail")
  end

  private

  def call_service(backup: mock_backup)
    described_class.call(backup)
  end
end
