FactoryBot.define do
  factory :track do
    title { "Track 1" }
    key { "C MAJOR" }
    bpm { 111 }
    plays { 0 }
    is_public { true }
    genre { "Trap" }
  end
end
