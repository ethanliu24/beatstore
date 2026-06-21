# frozen_string_literal: true

# https://chartkick.com/
class Api::MetricsController < ApplicationController
  before_action :return_if_not_admin
  before_action :set_window

  def stripe_checkout_intent
    render json: line_chart_metrics(Metrics::Name::STRIPE_CHECKOUT_INTENT)
  end

  private

  def line_chart_metrics(event_name, tags: {})
    relation = Metric
      .where(event_name:)
      .where(created_at: BuildTimeFrameWindowService.time_frame(window: @window)..Time.current)
      .where("tags @> ?", tags.to_json)

    metrics = BuildTimeFrameWindowService.group_metrics_by_time(
      relation,
      window: @window,
      column: :created_at
    )

    metrics.count
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
