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

  factory :non_exclusive_license, class: "License" do
    title { "Non Exclusive License" }
    price_cents { 1000 }
    currency { "USD" }
    country { "CA" }
    province { "ON" }
    contract_type { License.contract_types[:non_exclusive] }
    contract_details {
      {
        terms_of_years: 1,
        delivers_mp3: true,
        delivers_wav: false,
        delivers_stems: true,
        distribution_copies: 10000,
        streams_allowed: 10000,
        non_monetized_videos: 2,
        monetized_videos: 1,
        non_monetized_video_streams: 10000,
        monetized_video_streams: 1000,
        non_profitable_performances: 1,
        has_broadcasting_rights: true,
        radio_stations_allowed: 1,
        allow_profitable_performances: true,
        non_profitable_performances_allowed: true
      }
    }
    default_for_new { true }
  end
end
