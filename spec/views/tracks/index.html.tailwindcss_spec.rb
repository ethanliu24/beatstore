require 'rails_helper'

RSpec.describe "tracks/index", type: :view do
  before(:each) do
    assign(:tracks, [
      Track.create!(title: "Index Title 1", genre: Track::GENRES[0]),
      Track.create!(title: "Index Title 2", genre: Track::GENRES[0])
    ])
  end

  it "renders a list of tracks" do
    skip "add some examples to (or delete) #{__FILE__}"
  end
end
