require "rails_helper"

RSpec.describe Track, type: :model do
  describe "validations" do
    subject(:track) { build(:track) }

    it { should validate_presence_of(:title) }
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

    context "is_public validation" do
      it "coerces non-boolean values to boolean" do
        track = Track.new(is_public: true)
        expect(track.is_public).to be(true)

        track.is_public = nil
        track.save
        expect(track.is_public).to be(false)

        track.is_public = "string"
        expect(track.is_public).to be(true)

        track.is_public = 1
        expect(track.is_public).to be(true)

        track.is_public = false
        expect(track.is_public).to be(false)
      end
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

    context "file attachments" do
      let(:track_with_files) { build(:track_with_files) }

      it "is valid if no files are attached" do
        expect(subject).to be_valid
      end

      it "is valid if the mime types are correct" do
        expect(track_with_files.tagged_mp3.content_type).to eq("audio/mpeg")
        expect(track_with_files.untagged_mp3.content_type).to eq("audio/mpeg")
        expect(track_with_files.untagged_wav.content_type).to eq("audio/x-wav")
        expect(track_with_files.track_stems.content_type).to eq("application/zip")
        expect(track_with_files.cover_photo.content_type).to eq("image/png")
        expect(track_with_files).to be_valid
      end

      it "is invalid if mime types are incorrect" do
        track_with_files.tagged_mp3.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "track_stems.zip")),
          filename: "track_stems.zip",
          content_type: "application/zip"
        )

        track_with_files.cover_photo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "cover_photo.png")),
          filename: "cover_photo.png",
          content_type: "image/png"
        )

        track_with_files.untagged_wav.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_mp3.mp3")),
          filename: "untagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        track_with_files.track_stems.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_wav.wav")),
          filename: "untagged_wav.wav",
          content_type: "audio/x-wav"
        )

        track_with_files.cover_photo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
          filename: "tagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        expect(track_with_files).not_to be_valid
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
end
