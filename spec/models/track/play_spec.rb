RSpec.describe Track::Play, type: :model do
  describe "associations" do
    it { should belong_to(:user).optional }
    it { should belong_to(:track) }
  end
end
