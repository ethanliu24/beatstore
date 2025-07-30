# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::FindSimilarTracksService, type: :service do
  context "#call" do
    it "should recommend tracks other than the current track that's public and same genre/matching tags/within a bpm range" do
      track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
      Track::Tag.create!(name: "a", track_id: track.id)

      recommended_track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
      Track::Tag.create!(name: "a", track_id: recommended_track.id)

      unmatching_track = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)
      Track::Tag.create!(name: "c", track_id: unmatching_track.id)

      _private_track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: false)
      _not_recommended_track = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)

      similar_tracks = find_similar_tracks(track:)

      expect(similar_tracks.size).to eq(1)
      expect(similar_tracks.first).to eq(recommended_track)
    end

    it "should recommend tracks within a bpm range" do
      bpm = 100
      range = Tracks::FindSimilarTracksService::SIMILAR_TRACKS_BPM_RANGE
      track = Track.create!(title: "T", genre: Track::GENRES[0], bpm:, is_public: true)
      t1 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm - range, is_public: true)
      t2 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm + range, is_public: true)
      _t3 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm - range - 1, is_public: true)
      _t4 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm + range + 1, is_public: true)

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      similar_tracks.each do |track|
        expect([ t1, t2 ]).to include(track)
      end
    end

    it "should order tracks based on the most tags matched" do
      track = create(:track)
      rec_1 = create(:track)
      rec_2 = create(:track)

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
      track = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_1 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[-1], is_public: true)
      rec_2 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)

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
      track = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_1 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
      rec_2 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true, created_at: Time.current - 1.days)

      similar_tracks = find_similar_tracks(track:)
      expect(similar_tracks.size).to eq(2)
      expect(similar_tracks[0]).to eq(rec_1)
      expect(similar_tracks[1]).to eq(rec_2)
    end
  end

  private

  def find_similar_tracks(track:)
    Tracks::FindSimilarTracksService.new(track:).call
  end
end
