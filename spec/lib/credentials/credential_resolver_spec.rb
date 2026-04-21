# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Credentials::CredentialResolver do
  let(:test_class) do
    Class.new do
      include Credentials::CredentialResolver
      public :resolve_credential, :dependabot?
    end
  end

  let(:subject) { test_class.new }
  let(:namespace) { "Test" }

  describe "#resolve_credential" do
    context "when the credential exists in Rails.application.credentials" do
      it "returns the credential and ignores ENV" do
        allow(Rails.application.credentials).to receive(:dig).with(:test, :api_key).and_return("rails_secret")

        result = subject.resolve_credential(:test, :api_key, env_key: "TEST_KEY", namespace:)
        expect(result).to eq("rails_secret")
      end
    end

    context "when credential is missing but ENV key is present" do
      it "returns the ENV value" do
        allow(Rails.application.credentials).to receive(:dig).and_return(nil)
        allow(ENV).to receive(:[]).with("TEST_KEY").and_return("env_secret")

        result = subject.resolve_credential(:test, :api_key, env_key: "TEST_KEY", namespace: namespace)
        expect(result).to eq("env_secret")
      end
    end

    context "when both are missing" do
      it "raises a descriptive error" do
        allow(Rails.application.credentials).to receive(:dig).and_return(nil)
        allow(ENV).to receive(:[]).with("TEST_KEY").and_return(nil)

        expect {
          subject.resolve_credential(:test, :api_key, env_key: "TEST_KEY", namespace: namespace)
        }.to raise_error(RuntimeError, "Missing Test credential: test.api_key")
      end
    end
  end

  describe "#dependabot?" do
    it "returns true when the string is 'true' (case insensitive)" do
      allow(ENV).to receive(:[]).with("DEPENDABOT").and_return("TRUE")
      expect(subject.dependabot?).to be true
    end

    it "returns false for other values" do
      allow(ENV).to receive(:[]).with("DEPENDABOT").and_return("false")
      expect(subject.dependabot?).to be false
    end
  end
end
