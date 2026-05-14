# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcceptLegalPolicies, type: :model do
  let(:version_struct) { Struct.new(:tos, :privacy, :cookies) }
  let(:dummy_class) {
    Class.new do
      include AcceptLegalPolicies

      attr_reader :current_or_guest_user

      def initialize(user:)
        @current_or_guest_user = user
      end
    end
  }

  shared_examples "auto accept latest legal policies" do
    describe "#new_policies_for_user" do
      it "returns all versions when the user has not accepted any policies yet" do
        current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.0")

        allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

        expect(instance.new_policies_for_user).to eq({
          terms_of_service: "test-2.0",
          privacy: "test-1.1",
          cookies: "test-1.0"
        })
      end

      it "returns only the specific policies that have changed" do
        user.legal_policies_acceptance.update(
          tos_version: "test-1.0", privacy_version: "test-1.1", cookies_version: "test-1.0"
        )
        current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.0")

        allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)

        expect(instance.new_policies_for_user).to eq({ terms_of_service: "test-2.0" })
      end

      it "returns an empty hash when the user is fully up to date" do
        expect(instance.new_policies_for_user).to eq({})
      end
    end

    context "set policies" do
      before do
        user.legal_policies_acceptance.update(
          tos_version: "test-1.0", privacy_version: "test-1.0", cookies_version: "test-1.0"
        )

        current_versions = version_struct.new("test-2.0", "test-1.1", "test-1.5")
        allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)
      end

      describe "#accept_latest_policies!" do
        it "executes the service and updates the database when policies are pending" do
          acceptance = user.reload.legal_policies_acceptance.reload

          instance.accept_latest_policies!

          expect(acceptance.tos_version).to eq("test-2.0")
          expect(acceptance.privacy_version).to eq("test-1.1")
          expect(acceptance.cookies_version).to eq("test-1.5")
        end

        it "does not trigger a service execution or update when already up to date" do
          current_versions = version_struct.new("test-1.0", "test-1.0", "test-1.0")

          allow(Templates::LegalTemplates).to receive(:current_versions).and_return(current_versions)
          expect(Users::UpdateAcceptedLegalPoliciesService).not_to receive(:new)

          instance.accept_latest_policies!
        end
      end

      describe "#accept_latest_tos_policy!" do
        it "updates tos policy only" do
          acceptance = user.reload.legal_policies_acceptance.reload
          instance.accept_latest_tos_policy!

          expect(acceptance.tos_version).to eq("test-2.0")
          expect(acceptance.privacy_version).to eq("test-1.0")
          expect(acceptance.cookies_version).to eq("test-1.0")
        end
      end

      describe "#accept_latest_privacy_policy!" do
        it "updates privacy policy only" do
          acceptance = user.reload.legal_policies_acceptance.reload
          instance.accept_latest_privacy_policy!

          expect(acceptance.tos_version).to eq("test-1.0")
          expect(acceptance.privacy_version).to eq("test-1.1")
          expect(acceptance.cookies_version).to eq("test-1.0")
        end
      end

      describe "#accept_latest_cookies_policy!" do
        it "updates cookies policy only" do
          acceptance = user.reload.legal_policies_acceptance.reload
          instance.accept_latest_cookies_policy!

          expect(acceptance.tos_version).to eq("test-1.0")
          expect(acceptance.privacy_version).to eq("test-1.0")
          expect(acceptance.cookies_version).to eq("test-1.5")
        end
      end
    end
  end

  context "user is logged in" do
    let!(:user) { create(:user) }
    let(:instance) { dummy_class.new(user:) }

    include_examples "auto accept latest legal policies"
  end

  context "user is guest" do
    let!(:user) { create(:guest) }
    let(:instance) { dummy_class.new(user:) }

    include_examples "auto accept latest legal policies"
  end
end
