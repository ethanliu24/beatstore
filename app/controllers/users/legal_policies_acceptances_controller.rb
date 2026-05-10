class Users::LegalPoliciesAcceptancesController < ApplicationController
  def accept_all
    Users::UpdateAcceptedLegalPoliciesService.new(
      user: current_or_guest_user,
      **sanitize_acceptance_params
    )
  end

  # everything is neccessary for site to work at the moment, nothing is configurable yet.
  def accept_neccessary
    Users::UpdateAcceptedLegalPoliciesService.new(
      user: current_or_guest_user,
      **sanitize_acceptance_params
    )
  end

  private

  def sanitize_acceptance_params
    params.require(:legal_policies_acceptance).permit(
      :accepted_tos_version,
      :accepted_privacy_version,
      :accepted_cookies_version,
    )
  end
end
