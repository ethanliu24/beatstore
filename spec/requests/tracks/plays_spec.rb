require 'rails_helper'

RSpec.describe Tracks::PlaysController, type: :request do
  describe "POST /create" do
    it "creates a play if user is logged in" do
      user = create(:user)
      track = create(:track)
      sign_in user, scope: :user

      expect {
        post track_increment_plays_url(track)
      }.to change(Track::Play, :count).by(1)
      expect(response).to have_http_status(:no_content)

      track.reload
      expect(track.plays.count).to eq(1)
      expect(track.plays[0].track_id).to eq(track.id)
      expect(track.plays[0].user_id).to eq(user.id)
    end

    it "creates a play if user is not logged in" do
      track = create(:track)
      expect {
        post track_increment_plays_url(track)
      }.to change(Track::Play, :count).by(1)
      expect(response).to have_http_status(:no_content)

      track.reload
      expect(track.plays.count).to eq(1)
      expect(track.plays[0].track_id).to eq(track.id)
      expect(track.plays[0].user_id).to eq(nil)
    end

    it "does not create a play if track doesn't exist" do
      track_id = Track.maximum(:id).to_i + 1000
      expect {
        post track_increment_plays_url(track_id: track_id)
      }.to change(Track::Play, :count).by(0)
      expect(response).to have_http_status(404)
    end
  end
end
