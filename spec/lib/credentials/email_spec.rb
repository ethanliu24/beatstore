# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Credentials::Email do
  let(:namespace) { :email }

  describe ".producer_email" do
    context "when running in Dependabot" do
      it "returns the fallback email immediately" do
        allow(ENV).to receive(:[]).with("DEPENDABOT").and_return("true")

        # Ensure it NEVER even tries to resolve
        expect(Credentials::Email).not_to receive(:resolve_credential)
        expect(Credentials::Email.producer_email).to eq("producer@example.com")
      end
    end

    context "when NOT in Dependabot" do
      before { allow(ENV).to receive(:[]).with("DEPENDABOT").and_return(nil) }

      it "resolves the credential via the resolver" do
        expect(Credentials::Email).to receive(:resolve_credential)
          .with(:email, :producer, namespace:)
          .and_return("real-producer@company.com")

        expect(Credentials::Email.producer_email).to eq("real-producer@company.com")
      end
    end
  end

  describe ".domain_email (Environment Logic)" do
    before { allow(ENV).to receive(:[]).with("DEPENDABOT").and_return(nil) }

    context "in production" do
      it "uses the :prod key" do
        allow(Rails.env).to receive(:production?).and_return(true)

        expect(Credentials::Email).to receive(:resolve_credential)
          .with(:email, :domain, :prod, namespace:)

        Credentials::Email.domain_email
      end
    end

    context "in development/test" do
      it "uses the :dev key" do
        allow(Rails.env).to receive(:production?).and_return(false)

        expect(Credentials::Email).to receive(:resolve_credential)
          .with(:email, :domain, :dev, namespace:)

        Credentials::Email.domain_email
      end
    end
  end
end
