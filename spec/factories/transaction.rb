FactoryBot.define do
  factory :payment_transaction, class: "Transaction" do
    status { Transaction.statuses[:pending] }
    amount_cents { 1000 }
    currency { "USD" }

    association :order
  end
end
