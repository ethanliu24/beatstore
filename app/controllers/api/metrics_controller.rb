# frozen_string_literal: true

# https://chartkick.com/
class Api::MetricsController < ApplicationController
  before_action :return_if_not_admin
  before_action :set_window

  def stripe_checkout_intent
    relation = get_metrics_relation(Metrics::Name::STRIPE_CHECKOUT_INTENT)
    metrics = group_by_time(relation).count
    render json: metrics
  end

  private

  def get_metrics_relation(event_name, tags: {})
    time_frame = BuildTimeFrameWindowService.time_frame(window: @window)..Time.current
    Metric.where(event_name:, created_at: time_frame)
  end

  def group_by_time(relation)
    BuildTimeFrameWindowService.group_metrics_by_time(
      relation,
      window: @window,
      column: :created_at
    )
  end

  def set_window
    @window = params[:window] || WindowSize::ONE_DAY
  end

  def return_if_not_admin
    unless current_user&.admin?
      head :not_found and return
    end
  end
end
