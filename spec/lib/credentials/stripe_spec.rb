# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Credentials::Stripe do
  let(:namespace) { :stripe }

  describe "environment-based key resolution" do
    context "when in production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it "resolves the secret_key from the :live path" do
        expect(Credentials::Stripe).to receive(:resolve_credential)
          .with(:stripe, :live, :secret_key, namespace:)
          .and_return("sk_live_123")

        expect(Credentials::Stripe.secret_key).to eq("sk_live_123")
      end
    end

    context "when in development or test" do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it "resolves the public_key from the :test path" do
        expect(Credentials::Stripe).to receive(:resolve_credential)
          .with(:stripe, :test, :public_key, namespace:)
          .and_return("pk_test_456")

        expect(Credentials::Stripe.public_key).to eq("pk_test_456")
      end
    end
  end

  describe "specific methods" do
    it "calls resolve_credential for the webhook secret" do
      allow(Rails.env).to receive(:production?).and_return(false)

      expect(Credentials::Stripe).to receive(:resolve_credential)
        .with(:stripe, :test, :payments_webhook_secret, namespace:)

      Credentials::Stripe.payments_webhook_secret
    end
  end

  describe "when credentials are missing" do
    it "raises an error with the correct stripe namespace" do
      allow(Rails.application.credentials).to receive(:dig).and_return(nil)
      allow(ENV).to receive(:[]).and_return(nil)

      expect {
        Credentials::Stripe.secret_key
      }.to raise_error(RuntimeError, /Missing stripe credential/)
    end
  end
end
