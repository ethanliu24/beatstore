require 'rails_helper'

RSpec.describe Track::Tag, type: :model do
  let(:track) { create(:track) }
  subject { build(:track_tag, track: track) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:track_id) }

    it 'is invalid when name is blank' do
      subject.name = ''
      expect(subject).not_to be_valid
      expect(subject.errors.details[:name]).to include(hash_including(error: :blank))
    end

    it 'is invalid when name is too long' do
      subject.name = 'a' * 51
      expect(subject).not_to be_valid
      expect(subject.errors.details[:name]).to include(hash_including(error: :too_long))
    end

    it 'is valid with a name under 50 chars' do
      subject.name = 'melodic'
      expect(subject).to be_valid
    end

    context 'uniqueness scoped to track_id' do
      before do
        create(:track_tag, name: 'trap', track: track)
      end

      it 'is invalid with duplicate name for the same track' do
        duplicate_tag = build(:track_tag, name: 'trap', track: track)
        expect(duplicate_tag).not_to be_valid
        expect(duplicate_tag.errors.details[:name]).to include(hash_including(error: :taken))
      end

      it 'is valid with same name for different tracks' do
        other_track = create(:track)
        tag = build(:track_tag, name: 'trap', track: other_track)
        expect(tag).to be_valid
      end
    end
  end

  describe "associations" do
    it { should belong_to(:track) }
  end

  describe "names" do
    it "should return distinct tags" do
      t1 = create(:track)
      t2 = create(:track)

      create(:track_tag, name: "a", track: t1)
      create(:track_tag, name: "b", track: t1)
      create(:track_tag, name: "a", track: t2)

      names = described_class.names
      expect(names).to eq([ "a", "b" ])
    end

    it "should return tags in sorted lexicographically" do
      track = create(:track)

      create(:track_tag, name: "b", track:)
      create(:track_tag, name: "c", track:)
      create(:track_tag, name: "a", track:)

      names = described_class.names
      expect(names).to eq([ "a", "b", "c" ])
    end
  end
end
