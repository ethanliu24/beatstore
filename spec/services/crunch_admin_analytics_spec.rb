# frozen_string_literal: true

require "rails_helper"

RSpec.describe CrunchAdminAnalyticsService, type: :service do
  let(:window) { WindowSize::ONE_DAY }
  let(:service) { described_class.new(window_size: window) }

  context "#call" do
    describe "chronological stats" do
      it "returns plays, hearts, comments, and sales ordered by created_at" do
        play = create(:track_play, created_at: 1.hour.ago)
        create(:track_play, created_at: 2.hours.ago)

        heart = create(:track_heart, created_at: 2.hours.ago)
        create(:track_heart, created_at: 3.hours.ago)

        comment_old = create(:comment, created_at: 3.hours.ago)
        comment_new = create(:comment, created_at: 30.minutes.ago)

        transaction_old = create(:payment_transaction, amount_cents: 1500, status: :completed, created_at: 2.hours.ago)
        transaction_new = create(:payment_transaction, amount_cents: 2500, status: :completed, created_at: 1.hour.ago)

        service.instance_variable_set(:@stats_type, :chronological)
        result = service.call

        expect(result[:plays].first).to eq(play)
        expect(result[:hearts].first).to eq(heart)
        expect(result[:comments].first).to eq(comment_old)
        expect(result[:sales].first).to eq(transaction_old)
      end

      it "returns empty arrays if no records exist" do
        service.instance_variable_set(:@stats_type, :chronological)
        result = service.call

        expect(result[:plays]).to eq([])
        expect(result[:hearts]).to eq([])
        expect(result[:comments]).to eq([])
        expect(result[:sales]).to eq([])
      end
    end

    describe "cumulative stats" do
      it "returns counts and revenue for completed transactions" do
        create(:track_play)
        create(:track_play)
        create(:track_heart)
        create(:comment)
        create(:payment_transaction, amount_cents: 1500, status: :completed)
        create(:payment_transaction, amount_cents: 2500, status: :completed)

        service.instance_variable_set(:@stats_type, :cumulative)
        result = service.call

        expect(result[:plays]).to eq(2)
        expect(result[:hearts]).to eq(1)
        expect(result[:comments]).to eq(1)
        expect(result[:revenue]).to eq(Money.new(4000).format)
      end

      it "ignores transactions that are not completed" do
        create(:payment_transaction, amount_cents: 1000, status: :pending)

        service.instance_variable_set(:@stats_type, :cumulative)
        result = service.call

        expect(result[:revenue]).to eq(Money.new(0).format)
      end
    end
  end
end
