FactoryBot.define do
  factory :license do
    title { "Test" }
    price_cents { 1000 }
    currency { "USD" }
    contract_type { License.contract_types[:free] }
    contract_details { {} }
    default_for_new { true }
  end
end
