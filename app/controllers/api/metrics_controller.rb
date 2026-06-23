# frozen_string_literal: true

# https://chartkick.com/
class Api::MetricsController < ApplicationController
  before_action :return_if_not_admin
  before_action :set_window

  def stripe_checkout_intent
    metrics = Metrics::BuildChartMetricsService
      .new(event_name: Metrics::Name::STRIPE_CHECKOUT_INTENT, window: @window)
      .line_chart_metrics

      render json: metrics
  end

  def stripe_one_time_payment
    metrics = Metrics::BuildChartMetricsService
      .new(event_name: Metrics::Name::STRIPE_ONE_TIME_PAYMENT, window: @window)
      .line_chart_metrics

    render json: metrics
  end

  private

  def set_window
    @window = params.require(:window)
  end

  def return_if_not_admin
    unless current_user&.admin?
      head :not_found and return
    end
  end
end
