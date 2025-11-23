# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snapshots::TakeLicenseSnapshotService, type: :service do
  let(:license) { create(:license) }

  it "should build the snapshot with the correct contents" do
    expected_snapshot = {
      "id" => license.id,
      "title" => license.title,
      "description" => license.description,
      "price_cents" => license.price_cents,
      "currency" => license.currency,
      "contract_type" => license.contract_type,
      "contract_details" => license.contract_details,
      "country" => license.country,
      "province" => license.province,
      "default_for_new" => license.default_for_new,
      "created_at" => license.created_at,
      "updated_at" => license.updated_at,
      "discarded_at" => license.discarded_at
    }

    actual_snapshot = call_service(license:)

    expect(actual_snapshot).to eq(expected_snapshot)
  end

  def call_service(license:)
    Snapshots::TakeLicenseSnapshotService.new(license:).call
  end
end
