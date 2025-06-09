require "rails_helper"

RSpec.describe Track, type: :model do
  describe "validations" do
    subject(:track) { build(:track) }

    it { should validate_presence_of(:title) }
    it { should validate_inclusion_of(:is_public).in_array([ true, false ]) }
    it { should validate_numericality_of(:bpm).only_integer.is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:plays).only_integer.is_greater_than_or_equal_to(0) }

    it "is valid with valid attributes" do
      subject.plays = 0
      subject.bpm = 120
      subject.key = "C MAJOR"
      expect(subject).to be_valid
    end

    it "allows nil bpm but only accepts positive integers if present" do
      subject.bpm = nil
      expect(subject).to be_valid

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



  describe "associations" do
    it { should have_many(:hearts).dependent(:destroy) }
    it { should have_many(:hearted_by_users).through(:hearts).source(:user) }

    it { should have_one_attached(:tagged_mp3) }
    it { should have_one_attached(:untagged_mp3) }
    it { should have_one_attached(:untagged_wav) }
    it { should have_one_attached(:track_stems) }
    it { should have_one_attached(:project_file) }
    it { should have_one_attached(:cover_photo) }
  end
end
