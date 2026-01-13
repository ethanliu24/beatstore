FactoryBot.define do
  factory :inbound_email do
    name { "John Doe" }
    email { "customer@example.com" }
    subject { "Test" }
    message { "This is a test." }
  end
end
