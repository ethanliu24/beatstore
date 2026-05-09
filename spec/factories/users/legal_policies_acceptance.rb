FactoryBot.define do
  factory :legal_policiesacceptance, class: "Users::LegalPoliciesAcceptance" do
    association :user
    tos_version { "V1" }
    tos_accepted_at { Time.now }
    privacy_version { "V1" }
    privacy_accepted_at { Time.now }
    cookies_version { "V1" }
    cookies_accepted_at { Time.now }
  end
end
