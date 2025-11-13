# frozen_string_literal: true

require "rails_helper"

RSpec.describe CrunchAdminAnalyticsService, type: :service do
  describe "#call" do
    it "returns cumulative and chronological stats" do
      user = create(:user)
      order = create(:order, user:)
      create(:track_play, created_at: 2.hours.ago, user:)
      create(:track_play, created_at: 1.hour.ago, user:)
      create(:track_heart, created_at: 3.hours.ago, user:)
      create(:comment, created_at: 1.hour.ago, user:)
      create(:comment, created_at: 10.minutes.ago, user:)
      create(:payment_transaction, amount_cents: 1500, status: :completed, created_at: 2.hours.ago, order:)
      create(:payment_transaction, amount_cents: 2500, status: :completed, created_at: 1.hour.ago, order:)
      create(:payment_transaction, amount_cents: 9999, status: :pending, created_at: 1.hour.ago, order:)
      create(:free_download, created_at: 1.hour.ago, user:)
      create(:free_download, created_at: 2.days.ago, user:)

      cum_stats, chron_stats = call_service(window_size: WindowSize::ONE_DAY)

      # cumulative
      expect(cum_stats[:plays]).to eq(2)
      expect(cum_stats[:hearts]).to eq(1)
      expect(cum_stats[:comments]).to eq(2)
      expect(cum_stats[:sales]).to eq(Money.new(4000).format) # 1500 + 2500
      expect(cum_stats[:free_downloads]).to eq(1)

      # chronological
      expect(chron_stats[:plays]).to be_a(Hash)
      expect(chron_stats[:hearts]).to be_a(Hash)
      expect(chron_stats[:comments]).to be_a(Hash)
      expect(chron_stats[:sales]).to be_a(Hash)
      expect(chron_stats[:free_downloads]).to be_a(Hash)

      expect(chron_stats[:plays].values.all? { |v| v.is_a?(Integer) }).to be true
      expect(chron_stats[:sales].values.all? { |v| v.is_a?(Float) || v.is_a?(Numeric) }).to be true
    end

    it "returns zeroed cumulative stats and empty chron stats when no records exist" do
      cum_stats, chron_stats = call_service(window_size: WindowSize::ONE_DAY)

      expect(cum_stats[:plays]).to eq(0)
      expect(cum_stats[:hearts]).to eq(0)
      expect(cum_stats[:comments]).to eq(0)
      expect(cum_stats[:sales]).to eq(Money.new(0).format)
      expect(cum_stats[:free_downloads]).to eq(0)

      expect(chron_stats[:plays]).to eq({})
      expect(chron_stats[:hearts]).to eq({})
      expect(chron_stats[:comments]).to eq({})
      expect(chron_stats[:sales]).to eq({})
      expect(chron_stats[:free_downloads]).to eq({})
    end
  end

  private

  def call_service(window_size:)
    CrunchAdminAnalyticsService.new(window_size:).call
  end
end
