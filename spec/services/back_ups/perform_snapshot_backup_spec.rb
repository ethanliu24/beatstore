# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackUps::PerformSnapshotBackupService do
  subject(:service) { described_class }

  let(:db_key) { Rails.env }
  let(:env_config) { Rails.configuration.database_configuration[Rails.env] }
  let(:backup) {
    BackUps::DumpDatabaseService::Result.new(
      success: true,
      filename: "backup.dump",
      content_type: "application/octet-stream",
      path: ".",
    )
  }
  let(:backup_service) { instance_double(BackUps::DumpDatabaseService, perform: backup) }
  let(:upload_service) { instance_double(BackUps::UploadToCloudService) }

  before do
    allow(BackUps::DumpDatabaseService)
      .to receive(:new)
      .with(env_config)
      .and_return(backup_service)

    allow(upload_service).to receive(:call)

    allow(BackUps::CleanUpBackupArtifactsService)
      .to receive(:call)

    allow(Rails.error).to receive(:handle).and_yield
  end

  describe "#call" do
    context "when database config does not exist" do
      before do
        allow(Rails.configuration).to receive(:database_configuration)
          .and_return(Rails.env => {})
      end

      it "returns nil" do
        expect(service.call(db_key, upload_service)).to be_nil
      end

      it "does not attempt a backup" do
        service.call(db_key, upload_service)

        expect(BackUps::DumpDatabaseService).not_to have_received(:new)
      end
    end

    context "when upload service is the wrong type" do
      let(:wrong_service) { Object.new }

      it "raises ArgumentError" do
        expect {
          service.call(db_key, wrong_service)
        }.to raise_error(ArgumentError, "<upload_to_cloud_service> must respond to #call")
      end
    end

    context "when backup succeeds" do
      let(:backup_ok) { true }

      it "uploads the backup" do
        service.call(db_key, upload_service)

        expect(upload_service)
          .to have_received(:call)
          .with(backup, db_key: db_key)
      end

      it "cleans up backup artifacts" do
        service.call(db_key, upload_service)

        expect(BackUps::CleanUpBackupArtifactsService)
          .to have_received(:call)
          .with(backup)
      end

      it "emits success metric" do
        expect {
          service.call(db_key, upload_service)
        }.to change(Metric, :count).by(1)

        metric = Metric.last
        expect(metric.name).to eq(Metrics::Name::PERFORM_SNAPSHOT_BACKUP_RESULT)
        expect(metric.tags["status"]).to eq("success")
        expect(metric.tags["db_key"]).to eq(db_key)
      end
    end

    context "when backup fails" do
      before do
        expect(backup).to receive(:ok?).and_return(false)
      end

      it "raises SnapshotBackupFailed" do
        expect {
          service.call(db_key, upload_service)
        }.to raise_error(described_class::SnapshotBackupFailed, "backup file dump result not ok")
      end

      it "does not upload" do
        expect {
          service.call(db_key, upload_service)
        }.to raise_error(described_class::SnapshotBackupFailed)

        expect(upload_service).not_to have_received(:call)
      end

      it "cleans up backup artifacts" do
        expect {
          service.call(db_key, upload_service)
        }.to raise_error(described_class::SnapshotBackupFailed)

        expect(BackUps::CleanUpBackupArtifactsService)
          .to have_received(:call)
          .with(backup)
      end

      it "increments failed metrics" do
        expect {
          expect {
            service.call(db_key, upload_service)
          }.to raise_error(described_class::SnapshotBackupFailed)
        }.to change(Metric, :count).by(1)

        metric = Metric.last
        expect(metric.name).to eq(Metrics::Name::PERFORM_SNAPSHOT_BACKUP_RESULT)
        expect(metric.tags["status"]).to eq("fail")
        expect(metric.tags["db_key"]).to eq(db_key)
      end
    end

    context "when upload raises an exception" do
      let(:backup_ok) { true }
      let(:error) { StandardError.new("upload failed") }

      before do
        allow(upload_service)
          .to receive(:call)
          .and_raise(error)
      end

      it "handles the error through Rails.error.handle" do
        expect(Rails.error).to receive(:handle).and_yield

        expect {
          service.call(db_key, upload_service)
        }.to raise_error(error)
      end

      it "does not clean up artifacts" do
        expect {
          service.call(db_key, upload_service)
        }.to raise_error(error)

        expect(BackUps::CleanUpBackupArtifactsService)
          .not_to have_received(:call)
      end
    end
  end
end
