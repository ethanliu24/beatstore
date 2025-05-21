require "rails_helper"

RSpec.describe Track, type: :model do
  describe "validations" do
    subject { described_class.new(title: "Test Track", is_public: true) }

    it "is valid with valid attributes" do
      subject.hearts = 0
      subject.plays = 0
      subject.bpm = 120
      subject.key = "C MAJOR"
      expect(subject).to be_valid
    end

    it "requires a title" do
      subject.title = nil
      expect(subject).to be_invalid
    end

    it "requires hearts and plays to be non-negative integers" do
      subject.hearts = -1
      subject.plays = "abc"
      expect(subject).to be_invalid
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

    it "requires is_public to be true or false" do
      subject.is_public = nil
      expect(subject).to be_invalid
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
  end
end
