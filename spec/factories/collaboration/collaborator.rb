FactoryBot.define do
  factory :collaborator, class: Collaboration::Collaborator do
    name { "Diddy" }
    role { Collaboration::Collaborator.roles[:producer] }
    profit_share { 0.5 }
    publishing_share { 0.5 }
    notes { "IG: @diddy" }
    association :entity
  end
end
