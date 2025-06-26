require 'rails_helper'

RSpec.describe TracksController, type: :request do
  let(:valid_attributes) {
    {
      title: "Valid Track Title",
      key: "C MAJOR",
      bpm: 111,
      genre: Track::GENRES[0]
    }
  }

  let(:invalid_attributes) {
    {
      title: nil,
      artist: ""
    }
  }

  describe "GET /index" do
    it "renders a successful response" do
      Track.create! valid_attributes
      get tracks_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      track = Track.create! valid_attributes
      get track_url(track)
      expect(response).to be_successful
    end
  end
end
