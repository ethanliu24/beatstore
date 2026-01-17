require "stripe"

Stripe.api_key = Rails.application.credentials.dig(
  :stripe,
  Rails.env.production? ? :live : :test,
  :secret_key
)
