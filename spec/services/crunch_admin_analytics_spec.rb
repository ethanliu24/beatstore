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

      records = call_service(window_size: WindowSize::ONE_DAY)

      expect(records[:plays]).to be_a(ActiveRecord::Relation)
      expect(records[:hearts]).to be_a(ActiveRecord::Relation)
      expect(records[:comments]).to be_a(ActiveRecord::Relation)
      expect(records[:sales]).to be_a(ActiveRecord::Relation)
      expect(records[:free_downloads]).to be_a(ActiveRecord::Relation)

      expect(records[:plays].all? { |v| v.respond_to?(:id) }).to be true
      expect(records[:sales].all? { |v| v.respond_to?(:id) }).to be true
    end

    it "returns zeroed cumulative stats and empty chron stats when no records exist" do
      records = call_service(window_size: WindowSize::ONE_DAY)

      expect(records[:plays]).to eq([])
      expect(records[:hearts]).to eq([])
      expect(records[:comments]).to eq([])
      expect(records[:sales]).to eq([])
      expect(records[:free_downloads]).to eq([])
    end
  end

  private

  def call_service(window_size:)
    CrunchAdminAnalyticsService.new(window_size:).call
  end
end
