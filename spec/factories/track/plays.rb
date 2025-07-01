FactoryBot.define do
  factory :track_play, class: "Track::Play" do
    association :user
    association :track
  end
end
