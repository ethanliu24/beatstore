FactoryBot.define do
  factory :metric do
    event_name { Metrics::Name::Test }
    tags { {} }
    prunes_at { nil }
    created_at { Time.current }
  end
end
