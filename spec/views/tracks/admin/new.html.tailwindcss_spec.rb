require 'rails_helper'

RSpec.describe "admin/tracks/new", type: :view do
  before(:each) do
    assign(:track, build(:track)) # build, not create!
  end

  it "renders new track form" do
    render

    assert_select "form[action=?][method=?]", admin_tracks_path, "post" do
      assert_select "input[name=?]", "track[title]"
      # assert_select "input[name=?]", "track[key]"
      # assert_select "input[name=?]", "track[bpm]"
      # assert_select "input[name=?]", "track[hearts]"
      # assert_select "input[name=?]", "track[plays]"
      # assert_select "input[name=?]", "track[is_public]"

      # assert_select "input[name=?]", "track[tagged_mp3]"
      # assert_select "input[name=?]", "track[untagged_mp3]"
      # assert_select "input[name=?]", "track[untagged_wav]"
      # assert_select "input[name=?]", "track[track_stems]"
      # assert_select "input[name=?]", "track[project]"
      # assert_select "input[name=?]", "track[cover_photo]"
    end
  end
end
