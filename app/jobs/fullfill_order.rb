# frozen_string_literal: true

class OrderFullfillmentJob < ApplicationJob
  queue_as :high

  def perform(order:, stripe_checkout_session:)
  end
end
