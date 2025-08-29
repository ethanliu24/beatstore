# frozen_string_literal: true

require "rails_helper"

RSpec.describe Licenses::LicensesTracksAssociation, type: :model do
  let(:track) { create(:track) }
  let(:license) { create(:license) }

  it "should create a record when an association is made between a track and a license" do
    expect(Licenses::LicensesTracksAssociation.count).to eq(0)

    track.licenses << license

    a = Licenses::LicensesTracksAssociation.last
    expect(Licenses::LicensesTracksAssociation.count).to eq(1)
    expect(a.track_id).to eq(track.id)
    expect(a.license_id).to eq(license.id)
  end

  it "should delete corresponding record when a track is deleted" do
    track.licenses << license
    track.destroy!

    expect(Licenses::LicensesTracksAssociation.count).to eq(0)
    expect(license.tracks).to be_empty
    expect(License.all).to include(license)
  end

  it "should delete corresponding record when a license is deleted" do
    track.licenses << license
    license.destroy!
    track.reload

    expect(Licenses::LicensesTracksAssociation.count).to eq(0)
    expect(track.licenses.empty?).to be(true)
    expect(Track.all).to include(track)
  end
end
