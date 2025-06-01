require 'rails_helper'

RSpec.describe "Hearts", type: :request do
  let(:user) { create(:user) }
  let(:track) { create(:track) }

  describe "when user is logged in" do
    context "POST #create" do
      before { sign_in user, scope: :user }

      it "creates a new heart for the track" do
        expect {
          post track_heart_path(track)
        }.to change(Heart, :count).by(1)

        expect(user.hearts.last.track).to eq(track)
        expect(response).to have_http_status(:no_content)
      end

      it "should do nothing if track does not exist" do
        non_existent_track_id = Track.last&.id.to_i + 1000

        expect {
          post track_heart_path(non_existent_track_id)
        }.not_to change(Heart, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "DELETE #destroy" do
      before { sign_in user, scope: :user }

      it "destroys a heart for the track" do
        post track_heart_path(track)
        expect(user.hearts.exists?(track_id: track.id)).to be_truthy

        expect {
          delete track_heart_path(track)
        }.to change(Heart, :count).by(-1)

        expect(user.hearts.exists?(track_id: track.id)).to be_falsey
        expect(response).to have_http_status(:no_content)
      end

      it "should do nothing if track does not exist" do
        non_existent_track_id = Track.last&.id.to_i + 1000

        expect {
          delete track_heart_path(non_existent_track_id)
        }.not_to change(Heart, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "when user is not logged in" do
    it "POST #create redirects to sign in page" do
      post track_heart_path(track)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "DELETE #destroy redirects to sign in page" do
    delete track_heart_path(track)
    expect(response).to redirect_to(new_user_session_path)
  end
  end
end
