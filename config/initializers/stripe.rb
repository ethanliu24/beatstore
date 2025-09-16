require "stripe"

STRIPE_CONFIG = Rails.application.credentials.dig(
  :stripe,
  Rails.env.production? ? :live : :test
)

# We'll have to skip Stripe configs in cases such as dependabot PRs,
# because dependabots cannot access project secrets so it fails
if STRIPE_CONFIG.present?
  Stripe.api_key = STRIPE_CONFIG[:secret_key]
  STRIPE_PAYMENTS_WEBHOOK_SECRET = STRIPE_CONFIG[:payments_webhook_secret]
end
