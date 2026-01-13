require "stripe"

PRODUCER_EMAIL = Rails.application.credentials.dig(:email, :producer)
DOMAIN_EMAIL = Rails.application.credentials.dig(
  :email,
  :domain,
  Rails.env.production? ? :prod : :dev
)
