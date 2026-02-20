FactoryBot.define do
  factory :track_recommendation, class: "TrackRecommendation" do
    group { "A" }
    tag_names { [ "a", "b" ] }
    disabled { false }
  end
end
