require "rails_helper"

RSpec.describe "admin/tracks/edit", type: :view do
  let(:track) { create(:track) }

  before do
    assign(:track, track)
  end

  it "renders the edit track form" do
    render

    assert_select "form[action=?][method=?]", admin_track_path(track), "post" do
      # hidden field to spoof PATCH method
      assert_select "input[name=_method][value=patch]", true
      assert_select "input[name=?]", "track[title]"
    end
  end
end
