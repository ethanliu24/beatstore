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

  context "logged in user" do
    let(:user) { create(:user) }

    before do
      sign_in user, scope: :user
    end

    describe "PUT /accept_all" do
      it "creates/updates acceptance with all versions" do
        put accept_all_users_legal_policies_acceptance_url, params: base_params

        acceptance = user.legal_policies_acceptance.reload

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

        acceptance = user.legal_policies_acceptance.reload

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq("1.0")
        expect(acceptance.cookies_version).to eq(cookies_before)
        expect(acceptance.tos_accepted_at).to eq(acceptance.privacy_accepted_at)
        expect(acceptance.tos_accepted_at).not_to eq(acceptance.cookies_accepted_at)
      end
    end

    describe "PUT /accept_neccessary" do
      it "accepts neccessary configs only" do
        put accept_necessary_users_legal_policies_acceptance_url, params: base_params

        acceptance = user.legal_policies_acceptance.reload

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq("1.0")
        expect(acceptance.cookies_version).to eq("1.0")
      end

      it "handles partially filled params for neccessary configs only" do
        partial_params = {
          legal_policies_acceptance: {
            accepted_tos_version: "1.0"
          }
        }

        privacy_before = user.legal_policies_acceptance.privacy_version
        cookies_before = user.legal_policies_acceptance.cookies_version

        put accept_necessary_users_legal_policies_acceptance_url, params: partial_params

        acceptance = user.legal_policies_acceptance.reload

        expect(acceptance.tos_version).to eq("1.0")
        expect(acceptance.privacy_version).to eq(privacy_before)
        expect(acceptance.cookies_version).to eq(cookies_before)
        expect(acceptance.tos_accepted_at).not_to eq(acceptance.privacy_accepted_at)
        expect(acceptance.cookies_accepted_at).to eq(acceptance.privacy_accepted_at)
      end
    end
  end
end
