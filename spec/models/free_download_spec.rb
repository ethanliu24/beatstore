# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeDownload, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:track).optional }
  end

  describe "foreign key behavior" do
    let!(:user) { create(:user) }
    let!(:track) { create(:track) }

    context "when user is deleted" do
      it "nullifies the user_id on associated free_downloads" do
        free_download = FreeDownload.create!(user:, track:)

        expect { user.destroy }.to change {
          free_download.reload.user_id
        }.from(user.id).to(nil)

        expect(FreeDownload.exists?(free_download.id)).to be true
      end
    end

    context "when track is deleted" do
      it "nullifies the track_id on associated free_downloads" do
        free_download = FreeDownload.create!(user:, track:)

        expect { track.destroy }.to change {
          free_download.reload.track_id
        }.from(track.id).to(nil)

        expect(FreeDownload.exists?(free_download.id)).to be true
      end
    end
  end
end
