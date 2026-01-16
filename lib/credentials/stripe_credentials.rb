# frozen_string_literal: true

require "stripe"

module StripeCredentials
  extend self
  include CredentialResolver

  def secret_key
    resolve_credential(namespace, app_env, :secret_key, namespace:)
  end

  def payments_webhook_secret
    resolve_credential(namespace, app_env, :payments_webhook_secret, namespace:)
  end

  def public_key
    resolve_credential(namespace, app_env, :public_key, namespace:)
  end

  private

  def namespace
    :stripe
  end

  def app_env
    Rails.env.production? ? :live : :test
  end
end
