require "stripe"

Stripe.api_key = if Rails.env.production?
  Rails.application.credentials.dig(:stripe, :secret_key)
else
  ENV["STRIPE_SECRET_KEY"]
end
