FactoryBot.define do
  factory :user do
    username { "customer" }
    email { "customer@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now } # skip email confirmation for tests
    role { :customer }
  end
end
