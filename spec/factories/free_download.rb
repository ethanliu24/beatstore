FactoryBot.define do
  factory :free_download do
    email { "admin@example.com" }
    customer_name { "John Doe" }

    association :user
    association :track

    trait :without_user do
      user { nil }
    end

    trait :without_track do
      track { nil }
    end
  end
end
