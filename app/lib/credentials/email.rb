# frozen_string_literal: true

module Credentials
  module Email
    extend self
    include CredentialResolver

    def producer_email
      resolve_credential(:email, :producer, namespace:)
    end

    def domain_email
      resolve_credential(:email, :domain, app_env, namespace:)
    end

    private

    def namespace
      :email
    end

    def app_env
      Rails.env.production? ? :prod : :dev
    end
  end
end
