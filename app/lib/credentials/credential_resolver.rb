# frozen_string_literal: true

module Credentials
  module CredentialResolver
    private

    def resolve_credential(*keys, env_key: nil, namespace:)
      Rails.application.credentials.dig(*keys) ||
        (env_key && ENV[env_key]) ||
        missing!(namespace, keys)
    end

    def missing!(namespace, keys)
      raise "Missing #{namespace} credential: #{keys.join('.')}"
    end
  end
end
