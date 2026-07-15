# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::UploadToCloudService do
  let(:mock_google_drive) { instance_double(Google::Apis::DriveV3::DriveService) }
  let(:mock_backup) {
    BackUps::DumpDatabaseService::Result.new(
      success: true,
      filename: "backup.dump",
      content_type: "application/octet-stream",
      path: "path/to/backup.dump",
      message: "",
      error: ""
    )
  }
  let(:mock_file_response) {
    instance_double(
      Google::Apis::DriveV3::File,
      id: "mock_file_id_123",
      name: "backup.dump",
      size: "1kb",
      parents: [ "primary" ],
      web_view_link: "https://google.com",
      md5_checksum: "mock_md5_checksum_123"
    )
  }

  before do
    allow(described_class.instance).to receive(:google_drive).and_return(mock_google_drive)
    allow(mock_google_drive).to receive(:create_file).and_return(mock_file_response)
  end

  it "should upload the backup file and return the file metadata uploaded" do
    file = call_service

    expect(file.id).to eq("mock_file_id_123")
    expect(file.name).to eq("backup.dump")
    expect(file.size).to eq("1kb")
    expect(file.parents).to eq([ "primary" ])
    expect(file.web_view_link).to eq("https://google.com")
    expect(file.md5_checksum).to eq("mock_md5_checksum_123")
  end

  it "should record a success metric with file metadata after upload" do
    expect {
      call_service
    }.to change(Metric, :count).by(1)

    metric = Metric.last
    expect(metric.name).to eq(Metrics::Name::BACKUP_GOOGLE_DRIVE_UPLOAD_RESULT)
    expect(metric.tags["status"]).to eq("success")
    expect(metric.tags["file_id"]).to eq("mock_file_id_123")
    expect(metric.tags["file_name"]).to eq("backup.dump")
    expect(metric.tags["file_size"]).to eq("1kb")
    expect(metric.tags["file_parents"]).to eq([ "primary" ])
    expect(metric.tags["file_web_view_link"]).to eq("https://google.com")
    expect(metric.tags["file_md5_checksum"]).to eq("mock_md5_checksum_123")
  end

  it "should raise an error if back up is not " do
    expect {
      call_service(backup: "backup")
    }.to raise_error(ArgumentError, "<backup> must be a BackUps::DumpDatabaseService::Result, but got String")
  end

  it "should raise an error if backup is not successful" do
    failed_backup = BackUps::DumpDatabaseService::Result.new(
      success: false,
      message: "Back up failed",
      error: "Unauthorized"
    )

    expect {
      call_service(backup: failed_backup)
    }.to raise_error(ArgumentError, "<backup> data dump is not successful, cannot upload")
  end

  it "should emit a metric with fail status if any error occurs and reraise it" do
    allow(mock_backup).to receive(:ok?).and_raise(StandardError)

    expect {
      expect {
        call_service
      }.to change(Metric, :count).by(1)
    }.to raise_error(StandardError)

    metric = Metric.last
    expect(metric.name).to eq(Metrics::Name::BACKUP_GOOGLE_DRIVE_UPLOAD_RESULT)
    expect(metric.tags["status"]).to eq("fail")
  end

  it "should raise an error if db_key is not valid" do
    expect {
      call_service(backup: mock_backup, db_key: :invalid)
    }.to raise_error(ArgumentError, "<db_key> 'invalid' is not a valid or defined database key, check config/database.yml")
  end

  it "should allow db_key as both of type String and Symbol" do
    expect {
      call_service(backup: mock_backup, db_key: :primary)
    }.to change(Metric, :count).by(1)

    expect {
      call_service(backup: mock_backup, db_key: "primary")
    }.to change(Metric, :count).by(1)
  end

  it "is a singleton class" do
    service_1 = described_class.instance
    service_2 = described_class.instance

    expect(service_1).to be(service_2)
  end

  private

  def call_service(backup: mock_backup, db_key: "primary")
    described_class.instance.call(backup, db_key:)
  end
end
