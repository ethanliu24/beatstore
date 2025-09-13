# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cart, type: :model do
  let(:subject) { build(:payment_transaction) }

  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:amount_cents) }
  it { should validate_presence_of(:currency) }

  it { should belong_to(:order) }
end
