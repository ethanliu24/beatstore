FactoryBot.define do
  factory :user do
    display_name { "Diddy" }
    username { "customer" }
    email { "customer@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now } # skip email confirmation for tests
    role { :customer }
  end

  factory :admin, class: "User" do
    display_name { "Admin" }
    username { "admin" }
    email { "admin@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now } # skip email confirmation for tests
    role { :admin }
  end
end
