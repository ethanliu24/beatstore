# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: current_or_guest_user.id
    end
  end

  let(:user) { create(:user) }

  it "returns current_user if logged in" do
    allow(controller).to receive(:current_user).and_return(user)
    get :index

    expect(response.body).to eq(user.id.to_s)
  end

  it "returns guest_user when no current_user" do
    allow(controller).to receive(:current_user).and_return(nil)

    expect(controller).to receive(:guest_user).and_call_original
    get :index

    user = User.find(response.body)

    expect(user.guest?).to be(true)
  end

  it "destroys guest user when logging in" do
    guest = create(:guest)
    user = create(:user)

    allow(controller).to receive(:current_user).and_return(user)
    session[:guest_user_id] = guest.id

    expect {
      get :index
    }.to change(User, :count).by(-1)

    expect(session[:guest_user_id]).to be_nil
    expect(response.body).to eq(user.id.to_s)

    # test info transfer after signing in
  end
end
