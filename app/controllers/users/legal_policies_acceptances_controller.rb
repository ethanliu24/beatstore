class Users::LegalPoliciesAcceptancesController < ApplicationController
  after_action :update_session_acceptance_state

  def accept_all
    Users::UpdateAcceptedLegalPoliciesService.new(
      user: current_or_guest_user,
      **sanitize_acceptance_params.to_h.symbolize_keys
    ).call
  end

  # everything is neccessary for site to work at the moment, nothing is configurable yet.
  def accept_necessary
    Users::UpdateAcceptedLegalPoliciesService.new(
      user: current_or_guest_user,
      **sanitize_acceptance_params.to_h.symbolize_keys
    ).call
  end

  private

  def update_session_acceptance_state
    acceptance = current_or_guest_user.legal_policies_acceptance
    session[:legal_policies_acceptance] = {
      tos_version: acceptance.tos_version,
      privacy_version: acceptance.privacy_version,
      cookies_version: acceptance.cookies_version
    }
  end

  def sanitize_acceptance_params
    params.require(:legal_policies_acceptance).permit(
      :accepted_tos_version,
      :accepted_privacy_version,
      :accepted_cookies_version,
    )
  end
end
