FactoryBot.define do
  factory :order do
    public_id { nil }
    subtotal_cents { 2000 }
    currency { "USD" }
    status { Order.statuses[:pending] }
    metadata { {} }

    association :user
  end
end
