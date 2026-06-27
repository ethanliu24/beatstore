# frozen_string_literal: true

# https://chartkick.com/
class Api::MetricsController < ApplicationController
  before_action :return_if_not_admin
  before_action :set_window

  def stripe_checkout_intent
    metrics = service(Metrics::Name::STRIPE_CHECKOUT_INTENT).line_chart_metrics
    render json: metrics
  end

  def stripe_one_time_payment
    metrics = service(Metrics::Name::STRIPE_ONE_TIME_PAYMENT).line_chart_metrics
    render json: metrics
  end

  def order_fulfillment_result
    metrics = service(Metrics::Name::ORDER_FULFILLMENT_RESULT).pie_chart_metrics(group: :status)
    render json: metrics
  end

  private

  def service(event_name)
    Metrics::BuildChartMetricsService.new(event_name:, window: @window)
  end

  def set_window
    @window = params.require(:window)
  end

  def return_if_not_admin
    unless current_user&.admin?
      head :not_found and return
    end
  end
end
