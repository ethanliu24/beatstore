FactoryBot.define do
  factory :license do
    title { "Test" }
    price_cents { 1000 }
    currency { "USD" }
    country { "CA" }
    province { "ON" }
    contract_type { License.contract_types[:free] }
    contract_details {
      {
        terms_of_years: 1,
        delivers_mp3: true,
        delivers_wav: false,
        delivers_stems: true
      }
    }
    default_for_new { true }
  end
end
