require "rails_helper"

RSpec.describe Track, type: :model do
  describe "validations" do
    subject(:track) { build(:track) }

    it { should validate_presence_of(:title) }
    it { should validate_inclusion_of(:is_public).in_array([ true, false ]) }
    it { should validate_presence_of(:bpm) }
    it { should validate_numericality_of(:bpm).only_integer.is_greater_than(0) }

    it "is valid with valid attributes" do
      subject.bpm = 120
      subject.key = "C MAJOR"
      expect(subject).to be_valid
    end

    it "only accepts positive integers" do
      subject.bpm = 0
      expect(subject).to be_invalid

      subject.bpm = -1
      expect(subject).to be_invalid

      subject.bpm = 100
      expect(subject).to be_valid
    end

    context "key validation" do
      it "accepts valid keys" do
        [ "C MAJOR", "A# MINOR", "Eb MINOR", "Gb MAJOR" ].each do |k|
          subject.key = k
          expect(subject).to be_valid, "#{k} should be valid"
        end
      end

      it "rejects invalid keys" do
        [ "C", "major", "C MAJ", "H MAJOR", "C# Minor", "B DIMINISHED" ].each do |k|
          subject.key = k
          expect(subject).to be_invalid, "#{k} should be invalid"
        end
      end
    end

    context "genre" do
      it "is valid with a valid genre" do
        Track::GENRES.each do |valid_genre|
          subject.genre = valid_genre
          expect(subject).to be_valid
        end
      end

      it "is invalid without a genre" do
        subject.genre = nil
        expect(subject).not_to be_valid
        expect(subject.errors.details[:genre]).to include(hash_including(error: :blank))
      end

      it "is invalid with an unknown genre" do
        subject.genre = "unknown_genre"
        expect(subject).not_to be_valid
        expect(subject.errors.details[:genre]).to include(hash_including(error: :inclusion))
      end
    end

    context "description" do
      it "is valid if description is blank" do
        subject.description = ""
        expect(subject).to be_valid
      end

      it "is valid if description is less than or equal to 200 characters" do
        subject.description = "a" * 200
        expect(subject).to be_valid
      end

      it "is invalid if description is longer than 200 characters" do
        subject.description = "a" * 201
        expect(subject).not_to be_valid
        expect(subject.errors.details[:description]).to include(hash_including(error: :too_long))
      end
    end
  end

  describe "destroy" do
    let(:user) { create(:user) }
    let(:track) { create(:track) }

    it "should successfully destroy track and nullify its play and hearts" do
      heart = create(:track_heart, track_id: track.id, user_id: user.id)
      play = create(:track_play, track_id: track.id, user_id: user.id)

      expect { track.destroy }.to change { Track.count }.by(-1)

      heart.reload
      play.reload

      expect(heart.track_id).to be_nil
      expect(play.track_id).to be_nil
      expect(heart.user_id).to eq(user.id)
      expect(play.user_id).to eq(user.id)
    end

    it "should delete all comments associated with it" do
      create(:comment, entity: track, user: user)
      create(:comment, entity: track, user: user)

      expect(track.comments.size).to eq(2)

      track.destroy!

      expect(track.comments.size).to eq(0)
    end
  end

  describe "associations" do
    it { should have_many(:hearts) }
    it { should have_many(:hearted_by_users).through(:hearts).source(:user) }
    it { should have_many(:plays) }
    it { should have_many(:comments) }

    it { should have_one_attached(:tagged_mp3) }
    it { should have_one_attached(:untagged_mp3) }
    it { should have_one_attached(:untagged_wav) }
    it { should have_one_attached(:track_stems) }
    it { should have_one_attached(:project_file) }
    it { should have_one_attached(:cover_photo) }
  end

  describe "scopes" do
    context "similar_tracks" do
      it "should recommend tracks other than the current track that's public and same genre/matching tags/within a bpm range" do
        track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
        Track::Tag.create!(name: "a", track_id: track.id)

        recommended_track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: true)
        Track::Tag.create!(name: "a", track_id: recommended_track.id)

        unmatching_track = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)
        Track::Tag.create!(name: "c", track_id: unmatching_track.id)

        _private_track = Track.create!(title: "T", genre: Track::GENRES[0], bpm: 100, is_public: false)
        _not_recommended_track = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: 1, is_public: true)

        similar_tracks = Track.similar_tracks(track)

        expect(similar_tracks.size).to eq(1)
        expect(similar_tracks.first).to eq(recommended_track)
      end

      it "should recommend tracks within a bpm range" do
        bpm = 100
        track = Track.create!(title: "T", genre: Track::GENRES[0], bpm:, is_public: true)
        t1 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm - Track::SIMILAR_TRACKS_BPM_RANGE, is_public: true)
        t2 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm + Track::SIMILAR_TRACKS_BPM_RANGE, is_public: true)
        _t3 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm - Track::SIMILAR_TRACKS_BPM_RANGE - 1, is_public: true)
        _t4 = Track.create!(title: "T", genre: Track::GENRES[-1], bpm: bpm + Track::SIMILAR_TRACKS_BPM_RANGE + 1, is_public: true)

        similar_tracks = Track.similar_tracks(track)
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

        similar_tracks = Track.similar_tracks(track)
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

        similar_tracks = Track.similar_tracks(track)
        expect(similar_tracks.size).to eq(2)
        expect(similar_tracks[0]).to eq(rec_1)
        expect(similar_tracks[1]).to eq(rec_2)
      end

      it "should order tracks by created date after matching tags and genres" do
        track = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
        rec_1 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true)
        rec_2 = Track.create!(title: "T", bpm: 111, genre: Track::GENRES[0], is_public: true, created_at: Time.current - 1.days)

        similar_tracks = Track.similar_tracks(track)
        expect(similar_tracks.size).to eq(2)
        expect(similar_tracks[0]).to eq(rec_1)
        expect(similar_tracks[1]).to eq(rec_2)
      end
    end
  end
end
