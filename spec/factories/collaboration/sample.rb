FactoryBot.define do
  factory :sample, class: Collaboration::Sample do
    name { "Sample" }
    artist { "Diddy" }
    link { "oil.com" }
    association :track
  end
end
