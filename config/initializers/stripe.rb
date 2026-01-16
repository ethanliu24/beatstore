require "stripe"

begin
  Stripe.api_key = ::Credentials::Stripe.secret_key
rescue => e
  Rails.logger.error("[Stripe] disabled: #{e.message}")
end
