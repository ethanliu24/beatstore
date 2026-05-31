FactoryBot.define do
  factory :stripe_payment_event do
    event_id { "stripe_payment_event" }

    association :order
    association :user
  end
end
