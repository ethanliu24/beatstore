FactoryBot.define do
  factory :user do
    display_name { "Diddy" }
    username { "customer" }
    email { "customer@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now }
    role { :customer }
  end

  factory :admin, class: "User" do
    display_name { "Admin" }
    username { "admin" }
    email { "admin@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now }
    role { :admin }
  end

  factory :guest, class: "User" do
    display_name { "guest" }
    username { "guest" }
    email { "guest@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now }
    role { :guest }
  end

  factory :user_with_pfp, class: "User" do
    display_name { "PFP" }
    username { "with_pfp" }
    email { "pfp@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.now }
    role { :customer }

    after(:build) do |user|
      user.profile_picture.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "users", "profile_picture.png")),
        filename: "profile_picture.png",
        content_type: "image/png"
      )
    end
  end
end
