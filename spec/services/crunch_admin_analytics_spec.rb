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
      create(:user, username: "deleted", email: "deleted@exmaple.com")

      records = call_service(window_size: WindowSize::ONE_DAY)

      expect(records[:plays]).to be_a(ActiveRecord::Relation)
      expect(records[:hearts]).to be_a(ActiveRecord::Relation)
      expect(records[:comments]).to be_a(ActiveRecord::Relation)
      expect(records[:sales]).to be_a(ActiveRecord::Relation)
      expect(records[:free_downloads]).to be_a(ActiveRecord::Relation)
      expect(records[:registered_users]).to be_a(ActiveRecord::Relation)
      expect(records[:deleted_users]).to be_a(ActiveRecord::Relation)

      expect(records[:plays].all? { |v| v.respond_to?(:id) }).to be true
      expect(records[:sales].all? { |v| v.respond_to?(:id) }).to be true
    end

    it "returns zeroed cumulative stats and empty chron stats when no records exist" do
      records = call_service(window_size: WindowSize::ONE_DAY)

      expect(records[:plays].count).to eq(0)
      expect(records[:hearts].count).to eq(0)
      expect(records[:comments].count).to eq(0)
      expect(records[:sales].count).to eq(0)
      expect(records[:free_downloads].count).to eq(0)
      expect(records[:registered_users].count).to eq(0)
      expect(records[:deleted_users].count).to eq(0)
    end
  end

  describe ".get_quick_stats" do
    it "returns a list of quick stats" do
      create(:user)

      quick_stats = call_service(window_size: WindowSize::ONE_DAY, raw_data: false)

      expect(quick_stats.is_a?(Array)).to eq(true)
      quick_stats.each do |qs|
        expect(qs.is_a?(QuickStat)).to eq(true)
      end
    end
  end

  private

  def call_service(window_size:, raw_data: true)
    service = CrunchAdminAnalyticsService.new(window_size:)
    if raw_data
      service.call
    else
      service.get_quick_stats
    end
  end
end
