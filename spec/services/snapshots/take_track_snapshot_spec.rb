# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snapshots::TakeTrackSnapshotService, type: :service do
  let(:track) { create(:track) }

  it "should build the snapshot with the correct contents" do
    expected_snapshot = {
      "id" => track.id,
      "title" => track.title,
      "key" => track.key,
      "bpm" => track.bpm,
      "is_public" => track.is_public,
      "created_at" => track.created_at,
      "updated_at" => track.updated_at,
      "genre" => track.genre,
      "description" => track.description,
      "discarded_at" => track.discarded_at
    }
    actual_snapshot = call_service(track:)

    expect(actual_snapshot).to eq(expected_snapshot)
  end

  def call_service(track:)
    Snapshots::TakeTrackSnapshotService.new(track:).call
  end
end
