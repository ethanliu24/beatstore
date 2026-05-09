# frozen_string_literal: true

class LegalTemplates < Templates
  VERSIONS = {
    tos: "2026.05.09.v1.0.0",
    privacy: "2026.04.28.v1.0.0",
    cookies: "2026.05.09.v1.0.0"
  }.freeze

  class << self
    def read_tos
      read_template("templates/legal/terms_of_service.md")
    end

    def read_privacy
      read_template("templates/legal/privacy_policy.md")
    end

    def read_cookies
      read_template("templates/legal/cookies_policy.md")
    end
  end
end

Rails.application.config.to_prepare do
  Rails.configuration.legal = {}
  Rails.configuration.legal[:terms_of_service] = LegalTemplates.read_tos
  Rails.configuration.legal[:privacy_policy] = LegalTemplates.read_privacy
  Rails.configuration.legal[:cookies_policy] = LegalTemplates.read_cookies
end
