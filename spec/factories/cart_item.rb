FactoryBot.define do
  factory :cart_item do
    quantity { 1 }

    association :cart
    association :license

    transient do
      product { association(:track) }
    end

    after(:build) do |cart_item, evaluator|
      cart_item.product = evaluator.product
    end
  end
end
