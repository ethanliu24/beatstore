FactoryBot.define do
  factory :track_heart, class: "Track::Heart" do
    association :user
    association :track
  end
end
