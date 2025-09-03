FactoryBot.define do
  factory :cart_item do
    association :cart
    association :license

    transient do
      product { association(:track) }
    end

    after(:build) do |cart, evaluator|
      cart.product = evaluator.product
    end
  end
end
