# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::LegalPoliciesAcceptancesController, type: :request do
  let(:base_params) do
    {
      legal_policies_acceptance: {
        accepted_tos_version: "1.0",
        accepted_privacy_version: "1.0",
        accepted_cookies_version: "1.0"
      }
    }
  end

  shared_examples "legal policies acceptance updates" do
    describe "PUT /accept_all" do
      it "creates/updates acceptance with all versions" do
        put accept_all_users_legal_policies_acceptance_url, params: base_params

        acceptance = user.reload.legal_policies_acceptance

        expect(acceptance.user).to eq(user)
        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq("1.0")
        expect(acceptance.cookies_version).to eq("1.0")
      end

      it "handles partially filled params" do
        partial_params = {
          legal_policies_acceptance: {
            accepted_tos_version: "1.0",
            accepted_privacy_version: "1.0"
          }
        }

        cookies_before = user.legal_policies_acceptance.cookies_version

        put accept_all_users_legal_policies_acceptance_url, params: partial_params

        acceptance = user.reload.legal_policies_acceptance

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq("1.0")
        expect(acceptance.cookies_version).to eq(cookies_before)
      end
    end

    describe "PUT /accept_necessary" do
      it "accepts necessary configs only" do
        put accept_necessary_users_legal_policies_acceptance_url, params: base_params

        acceptance = user.reload.legal_policies_acceptance

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq("1.0")
        expect(acceptance.cookies_version).to eq("1.0")
      end

      it "handles partially filled params for necessary configs only" do
        partial_params = {
          legal_policies_acceptance: {
            accepted_tos_version: "1.0"
          }
        }

        privacy_before = user.legal_policies_acceptance.privacy_version
        cookies_before = user.legal_policies_acceptance.cookies_version

        put accept_necessary_users_legal_policies_acceptance_url, params: partial_params

        acceptance = user.reload.legal_policies_acceptance

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq(privacy_before)
        expect(acceptance.cookies_version).to eq(cookies_before)
      end
    end
  end

  context "logged in user" do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    include_examples "legal policies acceptance updates"
  end

  context "guest user" do
    let(:user) { create(:guest) }

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_or_guest_user)
        .and_return(user)
    end

    include_examples "legal policies acceptance updates"
  end
end
