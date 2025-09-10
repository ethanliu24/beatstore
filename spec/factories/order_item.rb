FactoryBot.define do
  factory :order_item do
    is_immutable { false }
    quantity { 1 }
    unit_price_cents { 2000 }
    currency { "USD" }
    product_type { Track.name }
    product_snapshot { { test: "test" } }
    license_snapshot { { test: "test" } }

    association :order
  end
end
