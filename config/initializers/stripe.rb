require "stripe"

Stripe.api_key = Settings.stripe.secret_key
