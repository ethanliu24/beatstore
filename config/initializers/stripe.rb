require "stripe"

begin
  Stripe.api_key = StripeCredentials.api_key
rescue => e
  Rails.logger.error("[Stripe] disabled: #{e.message}")
end
