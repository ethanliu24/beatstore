require "stripe"

STRIPE_CONFIG = Rails.application.credentials.dig(
  :stripe,
  Rails.env.production? ? :live : :test
)

Stripe.api_key = STRIPE_CONFIG[:secret_key]
