module Users
  class UpdateAcceptedLegalPolicies
    def initialize(
      user:,
      accepted_tos_version: nil,
      accepted_privacy_version: nil,
      accepted_cookies_version: nil
    )
      @user = user
      @legal_policies_acceptance = user.legal_policies_acceptance
      @accepted_tos_version = accepted_tos_version
      @accepted_privacy_version = accepted_privacy_version
      @accepted_cookies_version = accepted_cookies_version
    end

    def call
      accepted_time = Time.current
      args = {}

      unless @accepted_tos_version.blank?
        args[:tos_version] = @accepted_tos_version
        args[:tos_accepted_at] = accepted_time
      end

      unless @accepted_privacy_version.blank?
        args[:privacy_version] = @accepted_privacy_version
        args[:privacy_accepted_at] = accepted_time
      end

      unless @accepted_cookies_version.blank?
        args[:cookies_version] = @accepted_cookies_version
        args[:cookies_accepted_at] = accepted_time
      end

      @legal_policies_acceptance.update!(**args)
    end
  end
end
