# frozen_string_literal: true

module Templates
  class LegalTemplates
    extend Templates::Reader

    class Versioning
      attr_accessor :tos, :privacy, :cookies

      def initialize(tos:, privacy:, cookies:)
        @tos = tos
        @privacy = privacy
        @cookies = cookies
      end

      def serialize
        {
          tos: @tos,
          privacy: @privacy,
          cookies: @cookies
        }.to_json
      end

      def self.deserialize(h)
        self.new(**h)
      end
    end

    VERSIONS = {
      tos: "2026.05.09.v1",
      privacy: "2026.04.28.v1",
      cookies: "2026.05.09.v1"
    }.freeze

    class << self
      def current_versions
        Templates::LegalTemplates::Versioning.new(
          tos: VERSIONS[:tos],
          privacy: VERSIONS[:privacy],
          cookies: VERSIONS[:cookies],
        )
      end

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
end
