# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::FindSimilarTracksService, type: :service do
  let(:license) { create(:non_exclusive_license) }

  context "#call" do
    it "should recommend tracks other than the current track that's public and same genre/matching tags/within a bpm range" do
      track = create(:track_with_files, title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
      track.licenses << license
      Track::Tag.create!(name: "a", track_id: track.id)

      recommended_track = create(:track_with_files, title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
      recommended_track.licenses << license
      Track::Tag.create!(name: "a", track_id: recommended_track.id)

      unmatching_track = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)
      unmatching_track.licenses << license
      Track::Tag.create!(name: "c", track_id: unmatching_track.id)

      private_track = create(:track_with_files, title: "T", genre: Track::GENRES[0], bpm: 100, is_public: false)
      private_track.licenses << license

      not_recommended_track = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)
      not_recommended_track.licenses << license

      similar_tracks = find_similar_tracks(track:)

      expect(similar_tracks.size).to eq(1)
      expect(similar_tracks.first).to eq(recommended_track)
    end

    it "should recommend tracks within a bpm range" do
      bpm = 100
      range = Tracks::FindSimilarTracksService::SIMILAR_TRACKS_BPM_RANGE
      track = create(:track_with_files, title: "T", genre: Track::GENRES[0], bpm:, is_public: true)
      track.licenses << license

      t1 = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: bpm - range, is_public: true)
      t2 = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: bpm + range, is_public: true)
      t3 = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: bpm - range - 1, is_public: true)
      t4 = create(:track_with_files, title: "T", genre: Track::GENRES[-1], bpm: bpm + range + 1, is_public: true)

      t1.licenses << license
      t2.licenses << license
      t3.licenses << license
      t4.licenses << license

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      similar_tracks.each do |track|
        expect([ t1, t2 ]).to include(track)
      end
    end

    it "should order tracks based on the most tags matched" do
      track = create(:track_with_files)
      rec_1 = create(:track_with_files)
      rec_2 = create(:track_with_files)

      track.licenses << license
      rec_1.licenses << license
      rec_2.licenses << license

      [ "a", "b", "c" ].each do |name|
        Track::Tag.create!(name:, track_id: track.id)
        Track::Tag.create!(name:, track_id: rec_1.id)
      end

      Track::Tag.create(name: "a", track_id: rec_2.id)

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      expect(similar_tracks[0]).to eq(rec_1)
      expect(similar_tracks[1]).to eq(rec_2)
    end

    it "should order tracks by the same genres first after matching tags" do
      track = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_1 = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[-1], is_public: true)
      rec_2 = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)

      track.licenses << license
      rec_1.licenses << license
      rec_2.licenses << license

      [ "a", "b" ].each do |name|
        Track::Tag.create!(name:, track_id: track.id)
        Track::Tag.create!(name:, track_id: rec_1.id)
      end

      Track::Tag.create!(name: "a", track_id: rec_2.id)

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      expect(similar_tracks[0]).to eq(rec_1)
      expect(similar_tracks[1]).to eq(rec_2)
    end

    it "should order tracks by created date after matching tags and genres" do
      track = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_1 = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_2 = create(:track_with_files, title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true, created_at: Time.current - 1.days)

      track.licenses << license
      rec_1.licenses << license
      rec_2.licenses << license

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      expect(similar_tracks[0]).to eq(rec_1)
      expect(similar_tracks[1]).to eq(rec_2)
    end

    it "is scoped in kept tracks" do
      track = create(:track)
      track.discard!
      track.reload
      similar_tracks = find_similar_tracks(track:)

      expect(similar_tracks.size).to eq(0)
    end
  end

  private

  def find_similar_tracks(track:)
    Tracks::FindSimilarTracksService.new(track:).call
  end
end
