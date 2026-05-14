# frozen_string_literal: true

module AcceptLegalPolicies
  extend ActiveSupport::Concern

  def new_policies_for_user
    versions = Templates::LegalTemplates.current_versions
    current_accepted = current_or_guest_user.legal_policies_acceptance

    new_tos_version = versions.tos != current_accepted.tos_version
    new_privacy_version = versions.privacy != current_accepted.privacy_version
    new_cookies_version = versions.cookies != current_accepted.cookies_version

    updated_versions = {}
    updated_versions[:terms_of_service] = versions.tos if new_tos_version
    updated_versions[:privacy] = versions.privacy if new_privacy_version
    updated_versions[:cookies] = versions.cookies if new_cookies_version

    updated_versions
  end

  def has_pending_policies?
    new_policies_for_user.any?
  end

  def accept_latest_policies!
    return unless has_pending_policies?

    Users::UpdateAcceptedLegalPoliciesService.new(
      user: current_or_guest_user,
      accepted_tos_version: current_versions.tos,
      accepted_privacy_version: current_versions.privacy,
      accepted_cookies_version: current_versions.cookies
    ).call
  end

  def accept_latest_tos_policy!
    Users::UpdateAcceptedLegalPoliciesService.new(
      user:, accepted_tos_version: current_versions.tos
    ).call
  end

  def accept_latest_privacy_policy!
    Users::UpdateAcceptedLegalPoliciesService.new(
      user:, accepted_privacy_version: current_versions.privacy
    ).call
  end

  def accept_latest_cookies_policy!
    Users::UpdateAcceptedLegalPoliciesService.new(
      user:, accepted_cookies_version: current_versions.cookies
    ).call
  end

  private

  def current_versions
    Templates::LegalTemplates.current_versions
  end

  def user
    current_or_guest_user
  end
end
