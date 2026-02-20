# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tracks::RecommendByGroupService, type: :service do
  let(:license) { create(:non_exclusive_license) }

  describe "#latest" do
    it "should return the latest available tracks within limit" do
      _t1 = create_track(title: "T1", created_at: Time.new(2025, 1, 1))
      t2 = create_track(title: "T2", created_at: Time.new(2026, 1, 1))
      latest = service(limit: 1).latest

      expect(latest.count).to eq(1)
      expect(latest.first).to eq(t2)
    end

    it "should not return unavailable tracks" do
      create(:track)
      latest = service(limit: 1).latest

      expect(Track.count).to eq(1)
      expect(latest).to be_empty
    end
  end

  describe "#popular" do
    it "returns available tracks by popularity ranking" do
      t1 = create_track(title: "T1")
      t2 = create_track(title: "T2")

      create(:track_play, track: t1, user: nil)
      create(:track_heart, track: t1, user: nil)
      create(:track_heart, track: t1, user: nil)

      create(:track_play, track: t2, user: nil)
      create(:track_heart, track: t2, user: nil)

      popular = service(limit: 2).popular(like_weight: 1)

      expect(popular.count).to eq(2)
      expect(popular.first).to eq(t1)
      expect(popular.last).to eq(t2)
    end

    it "returns available tracks within limit" do
      t1 = create_track(title: "T1")
      _t2 = create_track(title: "T2")
      create(:track_play, track: t1, user: nil)

      popular = service(limit: 1).popular(like_weight: 1)

      expect(popular.count).to eq(1)
      expect(popular.first).to eq(t1)
    end

    it "puts more weight on likes for popularity ranking" do
      t1 = create_track(title: "T1")
      t2 = create_track(title: "T2")

      create(:track_play, track: t1, user: nil)
      create(:track_play, track: t1, user: nil)

      create(:track_play, track: t2, user: nil)
      create(:track_heart, track: t2, user: nil)

      popular = service(limit: 2).popular(like_weight: 5)

      expect(popular.count).to eq(2)
      expect(popular.first).to eq(t2)
      expect(popular.last).to eq(t1)
    end

    it "should not return unavailable tracks" do
      create(:track)
      popular = service(limit: 1).popular

      expect(Track.count).to eq(1)
      expect(popular).to be_empty
    end
  end

  describe "#group_by_tags" do
    it "returns available tracks with ALL matching tags" do
      t1 = create_track(title: "T1")
      t2 = create_track(title: "T2")

      create(:track_tag, name: "a", track: t1)
      create(:track_tag, name: "b", track: t1)
      create(:track_tag, name: "a", track: t2)

      group = service(limit: 2).group_by_tags([ "a", "b" ], match: :all)

      expect(group.length).to eq(1)
      expect(group.first).to eq(t1)
    end

    it "returns available tracks with ANY matching tags" do
      t1 = create_track(title: "T1")
      t2 = create_track(title: "T2")

      create(:track_tag, name: "a", track: t1)
      create(:track_tag, name: "b", track: t1)
      create(:track_tag, name: "a", track: t2)

      group = service(limit: 2).group_by_tags([ "a", "b" ], match: :any)

      expect(group.length).to eq(2)
      expect(group).to include(t1)
      expect(group).to include(t2)
    end

    it "returns available tracks within limit" do
      t1 = create_track(title: "T1")
      t2 = create_track(title: "T2")

      create(:track_tag, name: "abc", track: t1)
      create(:track_tag, name: "abc", track: t2)

      group = service(limit: 1).group_by_tags("abc", match: :any)

      expect(group.count).to eq(1)
      expect(group.first).to eq(t1)
    end

    it "shuold take both string and array of strings as argument" do
      t1 = create_track(title: "T1")
      create(:track_tag, name: "abc", track: t1)

      group = service(limit: 1).group_by_tags([ "abc" ], match: :any)
      expect(group.count).to eq(1)
      expect(group.first).to eq(t1)

      group = service(limit: 1).group_by_tags("abc", match: :any)
      expect(group.count).to eq(1)
      expect(group.first).to eq(t1)
    end

    it "should not return unavailable tracks" do
      track = create(:track)
      create(:track_tag, name: "abc", track:)
      group = service(limit: 1).group_by_tags("abc", match: :any)

      expect(Track.count).to eq(1)
      expect(group).to be_empty
    end

    it "should throw an error if match is invalid" do
      expect {
        service(limit: 1).group_by_tags("abc", match: :invalid)
      }.to raise_error
    end
  end

  private

  def service(limit:)
    described_class.new(limit:)
  end

  def create_track(**kwargs)
    track = create(:track_with_files, **kwargs)
    track.licenses << license
    track
  end
end
