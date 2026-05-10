# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UpdateAcceptedLegalPoliciesService do
  let(:user) { create(:user) }
  let(:acceptance) { user.legal_policies_acceptance }

  describe "#call" do
    context "when only TOS is accepted" do
      it "updates only the TOS version and timestamp" do
        service = described_class.new(
          user: user,
          accepted_tos_version: "v1.0"
        )

        expect { service.call }.to change { acceptance.reload.tos_version }.to("v1.0")
          .and change { acceptance.tos_accepted_at }.from(nil)

        expect(acceptance.privacy_version).to be_empty
        expect(acceptance.cookies_version).to be_empty
      end
    end

    context "when multiple policies are accepted" do
      it "updates all provided versions simultaneously" do
        service = described_class.new(
          user: user,
          accepted_tos_version: "v2.1",
          accepted_privacy_version: "v1.5"
        )

        service.call
        acceptance.reload

        expect(acceptance.tos_version).to eq("v2.1")
        expect(acceptance.privacy_version).to eq("v1.5")
        expect(acceptance.tos_accepted_at).to be_within(1.second).of(Time.current)
        expect(acceptance.cookies_version).to be_empty
      end
    end

    context "with blank versions" do
      it "does not update fields if versions are nil or empty strings" do
        acceptance.update!(privacy_version: "v1", privacy_accepted_at: 1.day.ago)

        service = described_class.new(
          user: user,
          accepted_privacy_version: "",
          accepted_cookies_version: nil
        )

        expect { service.call }.not_to change { acceptance.reload.privacy_version }
        expect(acceptance.cookies_version).to be_empty
      end
    end

    context "time" do
      it "sets the exact frozen time for all updated policies" do
        freeze_time do
          now = Time.current
          service = described_class.new(
            user: user,
            accepted_tos_version: "v1",
          )

          service.call
          acceptance.reload

          expect(acceptance.tos_accepted_at).to eq(now)
        end
      end

      it "ensures time is consistent across the single service execution" do
        freeze_time do
          now = Time.current
          service = described_class.new(
            user: user,
            accepted_tos_version: "v1",
            accepted_privacy_version: "v1",
            accepted_cookies_version: "v1",
          )

          service.call
          acceptance.reload

          expect(acceptance.tos_accepted_at).to eq(acceptance.privacy_accepted_at)
          expect(acceptance.privacy_accepted_at).to eq(acceptance.cookies_accepted_at)
          expect(acceptance.cookies_accepted_at).to eq(now)
        end
      end
    end
  end
end
