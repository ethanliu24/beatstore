# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripePaymentEvent, type: :model do
  let(:subject) { build(:stripe_payment_event) }

  it { should validate_presence_of(:event_id) }
  it { should validate_uniqueness_of(:event_id) }

  it { should belong_to(:order).optional }
  it { should belong_to(:user).optional }
end
