FactoryBot.define do
  factory :heart do
    association :user
    association :track
  end
end
