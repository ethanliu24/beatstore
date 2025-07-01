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
      # assert_select "input[name=?]", "track[is_public]"
    end
  end
end
