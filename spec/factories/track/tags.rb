FactoryBot.define do
  factory :track_tag, class: "Track::Tag" do
    name { "lebron" }
    association :track
  end
end
